require "remedy/tuple"
require "remedy/ansi"
require "remedy/text_util"

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
    def initialize size, fill: " ", nl: ?\n, ellipsis: "…", charwidth: 1, fit: false, parent: nil
      raise ArgumentError, "size cannot be `nil'!" if size.nil?
      @charwidth = charwidth
      @size = size
      @fill = fill[0, charwidth]
      @nl = nl
      @ellipsis = ellipsis
      @buf = new_buf
      @fit = fit
      @parent = parent
    end
    attr_accessor :fill, :nl, :ellipsis, :charwidth, :fit, :parent

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
      self.size = compute_actual_size override_buf
      @buf = override_buf
    end

    # @return [Remedy::Tuple] the size of the buffer in rows and columns
    def size
      @size
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
    def reset!
      @buf = new_buf
    end

    # Set a new size for the screenbuffer.
    # @todo The buffer is not shrank or otherwise truncated when the size changes.
    #
    # @param new_size [Remedy::Tuple] the new size,
    #   as typically received from `Console.size` or
    #   `Console.set_console_resized_hook!`
    # @raise [ArgumentError] if passed anything other than a Remedy::Tuple
    def resize new_size
      raise ArgumentError unless new_size.is_a? Tuple
      # FIXME: @size is getting reset to old versions somehow.
      #   But if we determine the actual size and use that instead,
      #   then we work around that behavior.
      actual_size = compute_actual_size

      if new_size.height > actual_size.height then
        grow_by = new_size.height - actual_size.height
        grow_by.times do
          @buf << new_buf_line
        end
      end
      if new_size.width > actual_size.width then
        grow_by = new_size.width - actual_size.width
        @buf.each do |l|
          # TODO: handle char width?
          l << fill * grow_by
        end
      end

      @size = new_size.dup
    end
    alias_method :size=, :resize

    def compute_actual_size array2d = buf
      Tuple array2d.length, (array2d.map{|l|l.length}.max || 0)
    end

    private

    def new_buf
      Array.new(size.height) do
        new_buf_line
      end
    end

    def new_buf_line
      fill * size.width * charwidth
    end

    def replace_perline coords, value
      # Array() checks for `.to_a` on whatever is passed to it
      lines = Array(value).map do |line|
        TextUtil.nlclean line
      end.flatten

      lines.each.with_index do |line, index|
        new_coords = coords + Tuple(index,0)
        if new_coords.height >= size.height then
          if fit then
            grow_size = Tuple (new_coords.height + 1), size.width
            resize(grow_size)
            size.height = new_coords.height
          else
            return
          end
        end

        replace_inline new_coords, line
      end

      self
    end

    def replace_inline coords, value
      if fit then
        grow_size = Tuple size.height, value.length
        resize(grow_size)
        truncated_value = value # not truncated
      else
        truncated_value = value[0,size.width - coords.col]
        truncated_value[-1] = ellipsis[0,charwidth] if ellipsis && truncated_value.length < value.length
      end

      buf[coords.row][coords.col,truncated_value.length] = truncated_value
    end
  end
end
