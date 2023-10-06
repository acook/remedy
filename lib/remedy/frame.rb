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
      # :auto - the frame has no size of its own, it conforms to the size of its content
      # :fill - the frame tries to fill as much space as possible
      # Tuple - specify a Tuple to constrain it to a specific size
      # Tuple.zero is same as :auto
      @max_size = :auto

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
    attr_accessor :contents, :nl, :fill, :available_size, :max_size, :halign

    def to_a
      compile_contents
    end

    def to_s
      compile_contents.join nl
    end

    def to_ansi
      compile_contents.join ANSI.cursor.next_line
    end

    def compile_contents size = available_size
      contents.map{|c| Array c}.flatten.map do |line|
        if max_size == :auto then
          line
        elsif max_size == :fill && halign == :left then
          Align.left_p line, size, fill: fill
        elsif max_size == :fill && halign == :right then
          Align.right_p line, size, fill: fill
        elsif max_size == :fill && halign == :center then
          Align.h_center_p line, size, fill: fill
        else
          raise "Unknown alignment - halign:#{} max_size:#{max_size}"
        end
      end
    end
  end
end
