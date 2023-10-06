module Remedy
  module Align

    module_function

    # Center content with a single line by padding out the left and right sides.
    #
    # @param content [String] the line to be centered
    # @param size [Remedy::Tuple] a Tuple with a width - it controls the centering
    # @param fill [String] the string to fill the space with
    def h_center_p content, size, fill: " "
      head, tail = middle_spacing content.length, size.width
      (fill * head) + content + (fill * tail)
    end

    # Left align by padding the right side to fill out the total width.
    def left_p content, size, fill: " "
      space = size.width - content.length
      return content if space < 0
      content + (fill * space)
    end

    # Right align by padding the left side to fill out the total width.
    def right_p content, size, fill: " "
      space = size.width - content.length
      return content if space < 0
      (fill * space) + content
    end

    # Center content in the middle of a buffer, both vertically and horizontally.
    #
    # @param content [Remedy::Partial] any object that responds to `height`, `width`, and a `to_a` that returns an array of strings
    # @return [content] whatever was passed in as the `content` param will be returned
    def buffer_center content, screenbuffer
      voffset = middle content.height, screenbuffer.size.height
      hoffset = middle content.width, screenbuffer.size.width
      screenbuffer[voffset,hoffset] = content
    end

    # Given the actual space something takes up,
    #   determine what the offset to get it centered in the available space.
    #
    # @param actual [Numeric] the space already taken
    # @param available [Numeric] the available space
    # @return [Integer] the offset from the end of the availabe space to center the actual content
    def middle actual, available
      return 0 unless actual < available

      offset = ((available - actual) / 2.0).floor
    end

    # Given the actual space something takes up,
    #   determine what the offset to get it centered in the available space,
    #   including the trailing space remaining.
    #
    # @param actual [Numeric] the space already taken
    # @param available [Numeric] the available space
    # @return [Array<Integer>] two element Array with the remaining space on each side
    #   (since contents may be shifted to one side or the other by 1 space)
    def middle_spacing actual, available
      return [0,0] unless actual < available

      head = middle actual, available
      tail = available - (head + actual)

      [head, tail]
    end
  end
end
