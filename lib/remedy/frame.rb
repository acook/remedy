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

      # depth is the z index or layer, higher numbers cover lower numbers
      # if two frames have the same layer but would overlap, then the one added most recently should come out on top
      @depth = 0

      # arrangement, if this frame contains multiple content items, then they will be arranged according to this
      # :stacked, :columnar, :tabbed(?)
      @arragement = :stacked

      # the maximum size that this frame wants to be
      # zero means fill
      @max_size = Tuple.zero

      # empty list of contents
      @contents = Array.new

      # background fill
      @fill = " "

      # newline character
      @nl = ?\n
    end
    attr_accessor :contents, :nl, :fill

    def to_a
      compile_contents
    end

    def to_s
      compile_contents.join nl
    end

    def to_ansi
      compile_contents.join ANSI.cursor.next_line
    end

    def compile_contents
      contents.map{|c| Array c}.flatten
    end
  end
end
