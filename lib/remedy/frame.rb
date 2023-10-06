require "remedy/tuple"

module Remedy
  # Frames contain Panes and Panes contain Partials
  # Frames can be nested within other Frames or Panes
  class Frame
    def initialize
      # origin is where the inner pane will be attached to
      # :left, :right, :top, :bottom, :center
      @origin = :center

      # offset is what the offset from that origin the pane should be placed
      @offset = Tuple.zero

      # depth is the z index or layer, higher numbers cover lower numbers
      # if two panes have the same layer but would overlap, then the one added most recently should come out on top
      @depth = 0

      # arrangement, if this frame contains multiple panes, then they will be arranged according to this
      # :stacked, :columnar, :tabbed(?)
      @arragement = :stacked

      # the maximum size that this frame wants to be
      # zero means fill
      @max_size = Tuple.zero

      # empty list of panes
      @panes = Array.new

      # background fill
      @fill = " "

      # newline character
      @nl = ?\n
    end
    attr_accessor :panes, :nl, :fill

    def to_a
      compile_panes
    end

    def to_s
      compile_panes.join nl
    end

    def to_ansi
      compile_panes.join ANSI.cursor.next_line
    end

    def compile_panes
      panes
    end
  end
end
