require "remedy/tuple"
require "remedy/ansi"

module Remedy
  # A screenbuffer is an in-memory representation of the terminal display.
  # Even most modern terminals do not allow direct access to the character display array.
  # So we create our own, like a DOM, to do our work on before rendering it to the screen.
  class Screenbuffer

    # Create a new screenbuffer.
    #
    # @param size [Remedy::Tuple] the number of rows and columns to allocate
    # @param fill [String] a character to pre-fill the buffer with
    # @param nl [String] the sequence used to separate lines when converted to a string
    # @param ellipsis [String] the character used to indicate truncated lines,
    #   if set to `nil` then content will extend to the edge of the screen
    # @param charwidth [Numeric] in case we are able to support multiple character widths in the future
    def initialize size, fill: " ", nl: ?\n, ellipsis: "…", charwidth: 1
      @charwidth = charwidth
      @size = size
      @fill = fill[0, charwidth]
      @nl = nl
      @ellipsis = ellipsis
      @buf = new_buf
    end
    attr_accessor :fill, :nl, :ellipsis, :charwidth

    # Get the contents of the buffer at a given coordinate.
    #
    # @overload [] coords
    #   @param coords [Remedy::Tuple] the coordinates to read from
    #
    # @overload [] row, col
    #   @param row [Numeric] the row to read from, 0 indexed
    #   @param col [Numeric] the column to read from, 0 indexed
    #
    # @todo get more than single characters
    def [] *params
      coords = Tuple params.flatten
      buf[coords.row][coords.col]
    end

    # Replace the contents of the buffer at a given coordinate.
    #
    # @overload []= coords, value
    #   @param coords [Remedy::Tuple] the coordinates to begin replacing from
    #   @param value [String, Enumerable] the content to place into the screenbuffer
    #   Usage with Tuple coordinates and line array:
    #   ```ruby
    #   coords = Tuple 3, 4
    #   lines = ["foo\nbar", "baz"]
    #   screenbuffer[coords] = lines
    #   ```
    # @overload []= row, col, value
    #   @param row [Numeric] the row to start replacing from, 0 indexed
    #   @param col [Numeric] the column to start replacing from, 0 indexed
    #   @param value [String, Enumerable] the content to place into the screenbuffer
    #
    #   Usage with scalar coordinates and simple string:
    #   ```ruby
    #   row = 1
    #   col = 2
    #   screenbuffer[row, col] = "foo"
    #   ```
    def []= *params
      value = params.pop
      coords = Tuple params.flatten

      replace_perline coords, value
    end

    # @return [Array] the raw screenbuffer array
    def buf
      @buf ||= new_buf
    end

    # Replace the contents of the internal buffer.
    #
    # Primarily useful for testing.
    # Could also be used for double/triple buffering implementation.
    #
    # @param override_buf [Array<String>] the new replacement buffer contents
    def buf= override_buf
      self.size = Tuple override_buf.length, (override_buf.map{|l|l.length}.max || 0)
      @buf = override_buf
    end

    # @return [Remedy::Tuple] the size of the buffer in rows and columns
    def size
      @size
    end

    # Set a new size for the screenbuffer.
    # @note This will destroy the contents of the current buffer!
    #
    # @param new_size [Remedy::Tuple] the new size,
    #   as typically received from `Console.size` or
    #   `Console.set_console_resized_hook!`
    # @raise [ArgumentError] if passed anything other than a Remedy::Tuple
    def size= new_size
      raise ArgumentError unless new_size.is_a? Tuple

      if size != new_size then
        @size = new_size
        @buf = new_buf
      end
    end

    # @return [Array<String>] the contents of the buffer as an array of strings
    def to_a
      buf
    end

    # Convert screenbuffer to single String.
    # Concatenates the contents of the buffer with the `nl` attribute.
    def to_s
      buf.join nl
    end

    # Convert screenbuffer to single string for output to a display using ANSI line motions.
    # Standard newlines at screen edges cause many terminals to display extraneous empty lines.
    def to_ansi
      buf.join ANSI.cursor.next_line
    end

    # Reset contents of buffer to the empty state using the @fill character.
    def reset
      @buf = new_buf
    end

    private

    def new_buf
      Array.new(size.height) do
        fill * size.width * charwidth
      end
    end

    def replace_perline coords, value
      # Array() checks for `.to_a` on whatever is passed to it
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
