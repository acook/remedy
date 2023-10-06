require "remedy/tuple"

module Remedy
  # Frames contain Panes and Panes contain Partials
  # Frames can be nested within other Frames or Panes
  class Frame
    def initialize
      # origin is where the frame will be attached to
      # :left, :right, :top, :bottom, :center
      @origin = :center

      # offset is what the offset from that origin the frame should be placed
      @offset = Tuple.zero

      # horizontal alignment of contents
      # :left, :right, :center
      @halign = :left

      # vertical alignment of contents
      # :top, :bottom, :center
      @halign = :top

      # depth is the z index or layer, higher numbers cover lower numbers
      # if two frames have the same layer but would overlap, then the one added most recently should come out on top
      @depth = 0

      # arrangement, if this frame contains multiple content items, then they will be arranged according to this
      # :stacked, :columnar, :tabbed(?)
      @arragement = :stacked

      # spacing as to how multiple content items should be spaced
      # :none, :evenly
      @spacing = :none

      # the maximum size that this frame wants to be, the actual size may be smaller
      # :none - frame has no size, contents are not aligned
      # :auto - frame conforms to the size of its largest content and alignts to it
      # :fill - the frame tries to fill as much space as possible
      # Tuple - specify a Tuple to constrain it to a specific size
      # Tuple.zero is same as :auto
      @max_size = :none

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
    attr_accessor :contents, :nl, :fill, :available_size, :max_size, :halign, :valign, :origin

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

    def merge_contents
      contents.map{|c| Array c}.flatten
    end

    def compile_contents
      merged = merge_contents

      merged.map do |line|
        if max_size == :none then
          next line
        elsif max_size == :fill then
          size = available_size
        elsif max_size == :auto then
          size = sizeof merged
        elsif Tuple === max_size then
          size = max_size
        else
          raise "Unknown max_size:#{max_size}"
        end

        if halign == :left then
          Align.left_p line, size, fill: fill
        elsif halign == :right then
          Align.right_p line, size, fill: fill
        elsif halign == :center then
          Align.h_center_p line, size, fill: fill
        else
          raise "Unknown halign:#{halign}"
        end
      end
    end

    def sizeof content
      height = content.length
      width = content.map(&:length).max || 0
      Tuple height, width
    end
  end
end
