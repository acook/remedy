require 'remedy/view'
require 'remedy/size'
require 'remedy/content'
require 'remedy/console'
require 'remedy/ansi'

module Remedy
  class Viewport
    def draw(content, center = Size.new(0, 0), header = [], footer = [])
      range = range_find content, center, content_size(header, footer)

      viewable_content = if content.size.fits_into? range
                           content
                         else
                           content.excerpt(*range)
                         end

      view = View.new viewable_content, header, footer

      ANSI.screen.safe_reset!
      Console.output << view
    end

    def range_find(partial, center, heightwidth)
      row_size, col_size = heightwidth
      row_limit, col_limit = partial.size

      center_row, center_col = center

      row_range = center_range center_row, row_size, row_limit
      col_range = center_range center_col, col_size, col_limit
      [row_range, col_range]
    end

    def content_size(header, footer)
      trim = Size [header.length + footer.length, 0]
      size - trim
    end

    def size
      Size Console.size
    end

    def center_range(center, width, limit)
      range_start = center - (width / 2)

      range_start = limit - width if range_start + width > limit

      range_start = 0 if range_start < 0

      range_end = range_start + width

      (range_start...range_end)
    end
  end
end
