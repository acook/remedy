require "remedy/tuple"
require "remedy/align"
require "remedy/screenbuffer"

module Remedy
  # Frames contain Panes and Panes contain Partials
  # Frames can be nested within other Frames or Panes
  class Frame
    def initialize name: self.object_id
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
      # :stacked, :columnar, :tabbed(?)
      @arrangement = :stacked

      # spacing as to how multiple content items should be spaced
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

      # background fill
      @fill = " "

      # newline character
      @nl = ?\n
    end

    attr_accessor :vorigin, :horigin, :depth
    attr_accessor :name, :size, :available_size
    attr_accessor :nl, :fill, :halign, :valign
    attr_accessor :contents, :arrangement

    # Sets the offset from the origin point.
    # @note Positive offsets always move the frame right and down,
    #   so negative values are more useful when `horigin = :right` and/or `vorigin = :bottom`.
    # @return [Remedy::Tuple] the vertical and horizontal offset to apply
    attr_accessor :offset

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
        split line
      end.flatten

      height = lines.length
      width = lines.map(&:length).max || 0
      Tuple height, width
    end

    # @todo move this to a helper module or something
    def split line
      line.to_s.split(/\r\n|\n\r|\n|\r/)
    end

    def merge_contents
      merged = contents.map do |c|
        content = Array c

        content.map! do |line|
        split line
      end.flatten
      end

      arrange_contents merged
    end

    def compiled_size
      sizeof compile_contents
    end

    def compile_contents
      merged = merge_contents
      merged_size = sizeof merged
      compile_size = compute_actual_size(merged_size) or return merged

      buf = Screenbuffer.new compile_size, fill: fill, nl: nl

      hoffset = compute_horizontal_offset merged_size, compile_size
      voffset = compute_vertical_offset merged_size, compile_size

      align_contents! merged, merged_size

      buf[voffset,hoffset] = merged
      buf.to_a
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
        msize.width.times do |index|
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
      else
        raise "unknown arrangement: #{arrangement}"
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
