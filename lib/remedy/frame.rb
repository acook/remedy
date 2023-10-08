require "remedy/tuple"
require "remedy/align"
require "remedy/screenbuffer"
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
    attr_accessor :contents

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

    def to_a
      compile_contents
    end

    def to_s
      compile_contents.join nl
    end

    def to_ansi
      compile_contents.join ANSI.cursor.next_line
    end

    def content_size
      sizeof merge_contents
    end

    def sizeof content
      lines = Array(content).map do |line|
        nlsplit line
      end.flatten

      height = lines.length
      width = lines.map(&:length).max || 0
      Tuple height, width
    end

    # @todo move this to a helper module or something
    def nlsplit line
      line.split(/\r\n|\n\r|\n|\r/)
    end
    end

    def merge_contents
      if arrangement == :arbitrary then
        contents_to_arrange = contents.map do |c|
          c.available_size = available_size
          c.to_s
        end
      else
        contents_to_arrange = contents.map do |c|
          content = Array c
          content.map! do |line|
            nlsplit line
          end.flatten
        end

        arrange_contents contents_to_arrange
      end
    end

    def compiled_size
      sizeof compile_contents
    end

    def compile_contents
      merged = merge_contents
      merged_size = sizeof merged
      @computed_size = compute_actual_size(merged_size) or return merged

      if buffer then
        buffer.reset!
      else
        @buffer = Screenbuffer.new computed_size, fill: fill, nl: nl
      end

      hoffset = compute_horizontal_offset merged_size, computed_size
      voffset = compute_vertical_offset merged_size, computed_size

      align_contents! merged, merged_size

      buffer[voffset,hoffset] = merged
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

    def arrange_contents content_to_arrange
      case arrangement
      when :stacked
        # TODO: insert padding?
        content_to_arrange.flatten
      when :columnar
        msize = sizeof content_to_arrange.flatten
        result = Array.new
        msize.col.times do |index|
          fullline = ""
          content_to_arrange.each do |content|
            line = content[index]
            if line then
              fullline << line
            end
          end
          result << fullline
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

      # wrap all items in a Frame
      # this has the side effect of setting all arbitrary content to layer 0
      arranger_content = content_to_arrange.map do |frame|
        frame = Frame.new(content: frame) unless frame.is_a? Frame
        frame
      end

      arranger_content.sort_by(&:depth).each do |frame|
        frame.available_size = arrange_buffer.size
        content = frame.compile_contents
        fsize = frame.computed_size

        p size, fsize

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

        arrange_buffer[voffset,hoffset] = content
      end
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
  end
end
