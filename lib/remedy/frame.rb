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
      @valign = :top

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
    attr_accessor :contents, :nl, :fill, :available_size, :size, :halign, :valign, :origin

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

      if size == :none then
        return merged
      elsif size == :fill then
        compiled_size = available_size
      elsif size == :auto then
        compiled_size = sizeof merged
      elsif Tuple === size then
        compiled_size = size
      else
        raise "Unknown max_size:#{size}"
      end

      # TODO: this could probably be replaced with direct buffer insertions
      haligned = merged.map do |line|
        if halign == :left then
          Align.left_p line, compiled_size, fill: fill
        elsif halign == :right then
          Align.right_p line, compiled_size, fill: fill
        elsif halign == :center then
          Align.h_center_p line, compiled_size, fill: fill
        else
          raise "Unknown halign:#{halign}"
        end
      end

      buf = Screenbuffer.new compiled_size, fill: fill, nl: nl
      case valign
      when :top
        voffset = 0
      when :bottom
        voffset = compiled_size - merged.length
      when :center
        voffset = Align.mido merged.length, compiled_size.height
      else
        raise "Unknown valign:#{valign}"
      end

      buf[voffset,0] = haligned
      buf.to_a
    end

    def sizeof content
      height = content.length
      width = content.map(&:length).max || 0
      Tuple height, width
    end
  end
end
