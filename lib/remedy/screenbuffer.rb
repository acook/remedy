require 'remedy/tuple'

module Remedy
  # A screenbuffer is an in-memory representation of the terminal display.
  # Even most modern terminals do not allow direct access to the character display array.
  # So we create our own, like a DOM, to do our work on before rendering it to the screen.
  class Screenbuffer

    # Create a new screenbuffer.
    #
    # @param size [Remedy::Tuple] the number of rows and columns to allocate
    # @param fill: [String] a character to pre-fill the buffer with
    # @param nl: [String] the sequence used to separate lines when converted to a string
    def initialize size, fill: " ", nl: ?\n
      @size = size
      @fill = fill[0]
      @nl = nl
      @buf = new_buf
    end
    attr_accessor :size, :fill, :nl, :buf

    # Replace the contents of the buffer at a given coordinate (from top left).
    #
    # Usage with scalar coordinates and simple string:
    # ```ruby
    # row = 1
    # col = 2
    # screenbuffer[row, col] = "foo"
    # ```
    # Usage with Tuple coordinates and line array:
    # ```ruby
    # coords = Tuple 3, 4
    # lines = ["foo\nbar", "baz"]
    # screenbuffer[coords] = lines
    # ```
    #
    # @param coords [Remedy::Tuple] the coordinates to begin replacing from
    # @param row [Numeric] the row to start replacing from, 0 indexed
    # @param col [Numeric] the column to start replacing from, 0 indexed
    # @param value [String or Enumerable] the content to place into the screenbuffer
    #   (always the last argument)
    def []= *params
      value = params.pop
      coords = Tuple params.flatten

      replace_perline coords, value
    end

    # The raw screenbuffer array itself.
    def buf
      @buf ||= new_buf
    end

    def new_buf
      Array.new(size.height) do
        fill * size.width
      end
    end

    # Convert screenbuffer to single string.
    # Concatenates the contents of the buffer with the `nl` attribute.
    def to_s
      buf.join nl
    end

    private

    def replace_perline coords, value
      lines = Array(value).map do |line|
        split line
      end.flatten

      lines.each.with_index do |line, index|
        replace_inline(coords + Tuple(index,0), line)
      end
    end

    def replace_inline coords, value
      buf[coords.row][coords.col,value.length] = value
    end

    def split line
      line.split(/\r\n|\n\r|\n|\r/)
    end
  end
end
