require 'remedy/view'
require 'remedy/size'
require 'remedy/console'
require 'remedy/ansi'

module Remedy
  class Viewport
    def draw content, scroll = Tuple.zero, header = Partial.new, footer = Partial.new
      range = range_find content, scroll, available_space(header,footer)

      viewable_content = content.excerpt(*range)

      view = View.new viewable_content, header, footer

      ANSI.screen.safe_reset!
      Console.output << view
    end

    def range_find partial, scroll, available_heightwidth
      avail_height, avail_width = available_heightwidth
      partial_height, partial_width = partial.size

      center_row, center_col = scroll

      row_range = get_range center_row, partial_height, avail_height
      col_range = get_range center_col, partial_width, avail_width

      [row_range, col_range]
    end

    # This determines the maximum amount of room left available for Content
    # after taking into consideration the height of the Header and Footer
    def available_space header, footer
      trim = Tuple [header.height + footer.height, 0]
      size - trim
    end

    def size
      Console.size
    end

    def get_range offset, actual, available
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
