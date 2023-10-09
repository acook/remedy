require "remedy/tuple"
require "remedy/align"
require "remedy/screenbuffer"
require "remedy/text_util"
require "remedy"
require "pry"

module Remedy
  # Frames contain Panes and Panes contain Partials
  # Frames can be nested within other Frames or Panes
  class Frame
    def initialize name: self.object_id, content: nil
      @name = name

      # vorigin is where the frame will be attached vertically
      # :top, :bottom, :center
      @vorigin = :top

      # horigin is where the frame will be attached horizontally
      # :left, :right, :center
      @horigin = :left

      # offset is what the offset from that origin the frame should be placed
      @offset = Tuple.zero

      # horizontal alignment of contents
      # :left, :right, :center
      @halign = :left

      # vertical alignment of contents
      # :top, :bottom, :center
      @valign = :top

      # depth is the z index or layer, higher numbers cover lower numbers
      # if two frames have the same layer but would overlap, then the one added most recently should come out on top
      @depth = 0

      # arrangement, if this frame contains multiple content items, then they will be arranged according to this
      # :stacked, :columnar, :arbitrary, :tabbed(?)
      @arrangement = :stacked

      # spacing as to how multiple content items should be spaced in an arrangement
      # has no effect when `arrangement = :arbitrary`
      # :none, :evenly
      @spacing = :none

      # the maximum size that this frame wants to be, the actual size may be smaller
      # :none - frame has no size, contents are not aligned
      # :auto - frame conforms to the size of its largest content and alignts to it
      # :fill - the frame tries to fill as much space as possible
      # Tuple - specify a Tuple to constrain it to a specific size
      # Tuple.zero is same as :none
      @size = :none

      # this size is used when max_size is set to :fill
      # typically set by a screen object after resize
      @available_size = Tuple.zero

      # empty list of contents
      @contents = Array.new
      if content then
        @contents << content
      end

      # background fill
      @fill = " "

      # newline character
      @nl = ?\n
    end

    attr_accessor :vorigin, :horigin, :depth
    attr_accessor :name, :size, :available_size
    attr_accessor :nl, :fill, :halign, :valign


    # Determines how contents are arranged when compiling.
    #
    # Possible values are:
    #
    # - `:stacked`
    # - `:columnar`
    # - `:arbitrary`
    #
    # @return [Symbol] one of the preset arragements
    attr_accessor :arrangement

    # Sets the offset from the origin point.
    # @note Positive offsets always move the frame right and down,
    #   so negative values are more useful when `horigin = :right` and/or `vorigin = :bottom`.
    # @return [Remedy::Tuple] the vertical and horizontal offset to apply
    attr_accessor :offset

    # The computed size is the actual size of the Frame after taking into account all of the different factors.
    # @note This value is invalid until after the contents have been compiled.
    # @return [Remedy::Tuple,nil] the size Tuple or `nil` if the Frame has not yet been compiled
    attr_reader :computed_size

    # The cached Frame buffer from the last compilation.
    # @note This value is invalid until after the contents have been compiled.
    # @return [Remedy::Screenbuffer,nil] the buffer or `nil` if the Frame has not yet been compiled
    attr_accessor :buffer

    def << new_content
      if new_content.is_a? String or new_content.is_a? Array then
        conformed_content = TextUtil.nlclean(new_content)
      else
        conformed_content = new_content
      end
      @contents << conformed_content
    end

    def [] *index
      # Can't decide if this should seek into the contents array or into the rendered output
      #@contents[*index]
      to_a[*index]
    end

    def reset!
      @contents.clear
    end

    def to_a
      compile_contents
    end

    def to_s
      compile_contents.join nl
    end

    def to_str
      to_s
    end

    def to_ansi
      compile_contents.join ANSI.cursor.next_line
    end

    def content_size
      sizeof arrange_contents
    end

    def maxsizeof content_list
      content_sizes = content_list.map do |content|
        sizeof content
      end

      height = content_sizes.map(&:height).max || 0
      width = content_sizes.map(&:width).max || 0
      Tuple height, width
    end

    def sizeof content
      lines = TextUtil.nlclean(content, self).flatten(1)

      height = lines.length
      width = lines.map(&:length).max || 0
      Tuple height, width
    end

    def length
      if size == :none then
        content_size.width
      elsif computed_size then
        computed_size.width
      else
        compile_contents
        computed_size.width
      end
    end

    def compile_contents
      # TODO: insert dirty check and then skip the rest of this if no changes detected,
      #   also a param which overrides this
      c = arrange_contents
      csize = sizeof c
      @computed_size = compute_actual_size(csize) or return c

      if buffer then
        buffer.reset!
      else
        @buffer = Screenbuffer.new computed_size, fill: fill, nl: nl
      end

      hoffset = compute_horizontal_offset csize, computed_size
      voffset = compute_vertical_offset csize, computed_size

      align_contents! c, csize

      buffer[voffset,hoffset] = c
      buffer.to_a
    end

    def compute_actual_size merged_size
      if size == :none then
        # size none indicates that no further formatting should take place
        # when we return nil from here, it will just return the merged array of content
        return nil
      elsif size == :fill then
        compile_size = available_size
      elsif size == :auto then
        compile_size = merged_size
      elsif Tuple === size then
        compile_size = size.dup

        if size.height == 0 then
          compile_size[0] = available_size.height
        elsif size.height < 1 then
          compile_size[0] = (available_size.height * size.height).floor
        end

        if size.width == 0 then
          compile_size[1] = available_size.width
        elsif size.width < 1 then
          compile_size[1] = (available_size.width * size.width).floor
        end
      else
        raise "Unknown max_size:#{size}"
      end

      compile_size
    end

    def compute_horizontal_offset original_size, actual_size
      case halign
      when :left
        hoffset = 0
      when :right
        hoffset = actual_size.width - original_size.width
      when :center
        hoffset = Align.mido original_size.width, actual_size.width
      else
        raise "Unknown halign:#{halign}"
      end

      hoffset
    end

    def compute_vertical_offset original_size, actual_size
      case valign
      when :top
        voffset = 0
      when :bottom
        voffset = actual_size.height - original_size.height
      when :center
        voffset = Align.mido original_size.height, actual_size.height
      else
        raise "Unknown valign:#{valign}"
      end

      voffset
    end

    def arrange_contents
      content_to_arrange = @contents

      case arrangement
      when :stacked
        # TODO: insert padding?
        content_to_arrange.flatten
      when :columnar
        rows = maxsizeof(content_to_arrange).row
        result = Array.new
        rows.times do |row|
          arranged_line = ""
          content_to_arrange.each do |content|
            line = content[row]
            if line then
              arranged_line << line
            end
          end
          result << arranged_line
        end
        result.flatten
      when :arbitrary
        arrange_arbitrary content_to_arrange
      else
        raise "unknown arrangement: #{arrangement}"
      end
    end

    def arrange_arbitrary content_to_arrange
      arrange_buffer = Screenbuffer.new available_size, fill: fill

      result = depth_sort(content_to_arrange).each do |frame|
        frame.available_size = arrange_buffer.size
        content = frame.compile_contents
        fsize = frame.computed_size || frame.content_size

        case frame.vorigin
        when :top
          voffset = 0
        when :center
          voffset = Align.mido fsize.height, arrange_buffer.size.height
        when :bottom
          voffset = arrange_buffer.size.height - fsize.height
        else
          raise "Unknown vorigin:#{frame.vorigin}"
        end

        case frame.horigin
        when :left
          hoffset = 0
        when :center
          hoffset = Align.mido fsize.width, arrange_buffer.size.width
        when :right
          hoffset = arrange_buffer.size.width - fsize.width
        else
          raise "Unknown horigin:#{frame.horigin}"
        end

        voffset += frame.offset.height
        hoffset += frame.offset.width

        offset = Tuple voffset, hoffset

        arrange_buffer[offset] = content
      end

      arrange_buffer.to_a
    end

    def align_contents! content_to_align, original_size
      case halign
      when :left
        # noop
      when :right
        content_to_align.map! do |line|
          line = Align.right_p line, original_size, fill: fill
        end
      when :center
        content_to_align.map! do |line|
          line = Align.h_center_p line, original_size, fill: fill
        end
      else
        raise "Unknown halign:#{halign}"
      end
      content_to_align
    end

    def depth_sort list_of_content
      list_of_content.sort do |a,b|
        depthof(a) <=> depthof(b)
      end
    end

    def depthof content
      if content.is_a? Frame then
        content.depth
      else
        0
  end
end
