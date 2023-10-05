require 'remedy/view'
require 'remedy/tuple'
require 'remedy/console'
require 'remedy/ansi'

module Remedy

  # By default a Pane will fill all available area
  # If a Pane is constrained to a specific size, then it will only take up that space
  # Any content that wouldn't fit to the constrained size will be truncated
  class Pane
    def initialize size: Tuple.zero, content: Partial.new, viewport: Viewport.new
      @size = size
      @content = content
      @viewport = viewport
    end

    def draw content, scroll = Tuple.zero
      range = range_find @content, scroll, @viewport.size

      viewable_content = @content.excerpt *range

      @viewport.draw viewable_content
    end

    def range_find partial, scroll, available_heightwidth
      avail_height, avail_width = available_heightwidth
      partial_height, partial_width = partial.size

      center_row, center_col = scroll

      row_range = visible_range center_row, partial_height, avail_height
      col_range = visible_range center_col, partial_width, avail_width

      [row_range, col_range]
    end

    # This is the target size of this pane, but may still be truncated if there is not enough room
    def size
      Tuple(height, width)
    end

    def height
      if @size.height > 0 then
        @size.height
      else
        content_height
      end
    end

    def width
      if @size.width > 0 then
        @size.width
      else
        content_width
      end
    end

    def visible_range offset, actual, available
      # if the actual content can fit into the available space, then we're done
      return (0...actual) if actual <= available

      # otherwise start looking at the scrolling offset, if any

      # clamp the offset within the possible range of the actual content
      if offset < 0 then
        range_start = 0
      elsif offset > actual then
        range_start = actual
      else
        range_start = offset
      end

      # determine the subset of content that can be displayed
      range_end = range_start + (available - offset)

      (range_start...range_end)
    end

  end
end
