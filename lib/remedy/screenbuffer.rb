require 'remedy/tuple'

module Remedy
  # A screenbuffer is an in-memory representation of the terminal display.
  # Even most modern terminals do not allow direct access to the character display array.
  # So we create our own, like a DOM, to do our work on before rendering it to the screen.
  class Screenbuffer
    def initialize size, fill: " ", nl: ?\n
      @size = size
      @fill = fill[0]
      @nl = nl
      @buf = new_buf
    end
    attr_accessor :size, :fill, :nl, :buf

    def []= *params
      value = params.pop
      coords = params.flatten

      if coords.first.is_a? ::Remedy::Tuple then
        coords = coords.first
      end

      row = coords[0]
      col = coords[1]

      buf[row][col,value.length] = value
    end

    def buf
      @buf ||= new_buf
    end

    def new_buf
      Array.new(size.height) do
        fill * size.width
      end
    end

    def to_s
      buf.join nl
    end
  end
end
