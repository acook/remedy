require "remedy/tuple"
require "remedy/align"
require "remedy/screenbuffer"
require "remedy/text_util"
require "remedy"

module Remedy
  # Frames contain Panes and Panes contain Partials
  # Frames can be nested within other Frames or Panes
  class Frame
    def initialize name: self.object_id, content: nil, parent: nil
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
      # :auto - frame conforms to the size of its largest content and aligns to it
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
        self << content
      end

      # background fill
      @fill = " "

      # newline character
      @nl = ?\n

      @parent = parent
    end

    attr_accessor :vorigin, :horigin, :depth
    attr_accessor :name, :size, :available_size
    attr_accessor :nl, :fill, :halign, :valign
    attr_reader :contents
    attr_accessor :parent

    # Determines how contents are arranged when compiling.
    #
    # Possible values are:
    #
    # - `:stacked`
    # - `:columnar`
    # - `:arbitrary`
    #
    # @return [Symbol] one of the preset arrangements
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
      case new_content
      when String, Array
        conformed_content = TextUtil.nlclean(new_content)
      else
        conformed_content = new_content
      end
      @contents << conformed_content
    end

    def [] *index
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

      return c if size == :none

      csize = sizeof c
      @computed_size = compute_actual_size csize

      if buffer then
        buffer.reset!
        buffer.resize computed_size
      else
        @buffer = Screenbuffer.new computed_size, fill: fill, nl: nl, parent: self, name: "compile_contents"
      end

      hoffset = compute_horizontal_offset csize, computed_size
      voffset = compute_vertical_offset csize, computed_size

      align_contents! c, csize

      buffer[voffset,hoffset] = c
      buffer.to_a
    end

    # Determine what the actual output size would be based on the size option and contents.
    #
    # Most of the time the output size can be determined statically based on the available
    #   size information and the one parameter.
    #
    # In practice `:none` and `:auto` output the same maximum height and width - despite rendering differences.
    #   Technically, `:none` will always result in `content_size`,
    #   while `:auto` could in theory be further modified by the alignment and later processing.
    #
    # @parram arranged_size [Remedy::Tuple] an externally determined size after preprocessing
    # @return [Remedy::Tuple] output size in rows/height and columns/width
    def compute_actual_size arranged_size = content_size
      case size
      when :none
        # generally identical to `arranged_size`
        # if needed, using that here could save processing
        content_size
      when :fill
        available_size
      when :auto
        arranged_size
      when Tuple
        actual_size = size.dup

        if size.height == 0 then
          actual_size[0] = available_size.height
        elsif size.height < 1 then
          actual_size[0] = (available_size.height * size.height).floor
        end

        if size.width == 0 then
          actual_size[1] = available_size.width
        elsif size.width < 1 then
          actual_size[1] = (available_size.width * size.width).floor
        end

        actual_size
      else
        raise "Unknown max_size:#{size}"
      end
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
      content_to_arrange = depth_sort

      case arrangement
      when :stacked
        arrange_stacked content_to_arrange
      when :columnar
        arrange_columnar content_to_arrange
      when :arbitrary
        arrange_arbitrary content_to_arrange
      else
        raise "unknown arrangement: #{arrangement}"
      end
    end

    def arrange_stacked content_to_arrange
        # TODO: insert padding?
        content_to_arrange.map do |content|
          content.available_size = available_size if content.respond_to? :available_size
          content.to_a
        end.flatten
    end

    def arrange_arbitrary content_to_arrange
      if size.is_a? Tuple then
        buffer_size = size
      else
        buffer_size = available_size
        expand_buffer = available_size.zero?
      end
      arrange_buffer = Screenbuffer.new buffer_size, fit: expand_buffer, fill: fill, parent: self, name: "arrange_arbitrary"

      result = content_to_arrange.each do |frame|
        # special case handling of plain Strings and Arrays
        unless frame.is_a? Frame then
          arrange_buffer[Tuple.zero] = frame
          buffer_size = arrange_buffer.size
          next
        end

        # FIXME: what happens when the buffer size is zero? the buffer will grow, right?
        frame.available_size = buffer_size
        content = frame.compile_contents
        fsize = frame.computed_size || frame.content_size

        case frame.vorigin
        when :top
          voffset = 0
        when :center
          voffset = Align.mido fsize.height, buffer_size.height
        when :bottom
          voffset = Align.boto fsize.height, buffer_size.height
        else
          raise "Unknown vorigin:#{frame.vorigin}"
        end

        # this line works around an edge case where only :top vorigins would
        #   be rendered when available_size was zero and the frame size was :none
        voffset = 0 if frame.vorigin != :top && buffer_size.height == 0 && voffset < 0

        case frame.horigin
        when :left
          hoffset = 0
        when :center
          hoffset = Align.mido fsize.width, buffer_size.width
        when :right
          hoffset = Align.boto fsize.width, buffer_size.width
        else
          raise "Unknown horigin:#{frame.horigin}"
        end

        voffset += frame.offset.height
        hoffset += frame.offset.width

        offset = Tuple voffset, hoffset

        arrange_buffer[offset] = content
        buffer_size = arrange_buffer.size
      end

      arrange_buffer.to_a
    end

    def arrange_columnar content_to_arrange
      content_list = content_to_arrange
      rows = maxsizeof(content_list).row
      result = Array.new

      content_sizes = [0] # the first column starts with zero

      content_list.each_with_object(content_sizes).with_index do |(content, cs), i|
        content.available_size = available_size if content.respond_to? :available_size
        cs << sizeof(content).width + cs[i]
      end

      rows.times do |row|
        arranged_line = ""

        content_list.each.with_index do |content, index|
          line = content[row]
          if line then
            padding = fill * [content_sizes[index] - arranged_line.length, 0].max
            arranged_line << padding
            arranged_line << line
          end
        end
        result << arranged_line
      end
      result
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

    protected

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

    def depth_sort content_list = contents
      content_list.sort do |a,b|
        a.parent = self if a.respond_to? :parent=
        b.parent = self if b.respond_to? :parent=
        depthof(a) <=> depthof(b)
      end
    end

    def depthof content
      case content
      when Frame
        content.depth
      else
        0
      end
    end

  end # Frame class
end # Remedy module
