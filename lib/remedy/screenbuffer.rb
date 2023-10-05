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
    # @param elipsis: [String] the character used to indicate truncated lines,
    #   if set to `nil` then content will extend to the edge of the screen
    def initialize size, fill: " ", nl: ?\n, ellipsis: "…"
      @charwidth = 1 # in case we need to support multiple widths in the future
      @size = size
      @fill = fill[0, charwidth]
      @nl = nl
      @ellipsis = ellipsis
      @buf = new_buf
    end
    attr_accessor :size, :fill, :nl, :buf, :ellipsis, :charwidth

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

    # Convert screenbuffer to single string.
    # Concatenates the contents of the buffer with the `nl` attribute.
    def to_s
      buf.join nl
    end

    private

    def new_buf
      Array.new(size.height) do
        fill * size.width * charwidth
      end
    end

    def replace_perline coords, value
      lines = Array(value).map do |line|
        split line
      end.flatten

      lines.each.with_index do |line, index|
        new_coords = coords + Tuple(index,0)
        return if new_coords.height >= size.height
        replace_inline(new_coords, line)
      end
    end

    def replace_inline coords, value
      fit = value[0,size.width - coords.col]
      fit[-1] = ellipsis[0,charwidth] if ellipsis && fit.length < value.length
      buf[coords.row][coords.col,fit.length] = fit
    end

    def split line
      line.split(/\r\n|\n\r|\n|\r/)
    end
  end
end
