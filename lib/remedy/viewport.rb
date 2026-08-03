require 'remedy/view'
require 'remedy/tuple'
require 'remedy/console'
require 'remedy/ansi'
require 'remedy/pane'

module Remedy
  class Viewport < Pane
    def initialize content: Partial.new, header: Partial.new, footer: Partial.new
      @content = content
      @header = header
      @footer = footer
    end
    attr_accessor :content, :header, :footer

    def draw override = nil
      body = override || @content
      range = range_find body, Tuple.zero, available_space(@header, @footer)

      viewable_content = body.excerpt(*range)

      view = View.new viewable_content, @header, @footer

      ANSI.screen.safe_reset!
      Console.output << view
    end

    def size
      Console.size
    end

    def height
      @size.height
    end

    def width
      @size.width
    end

    # This determines the maximum amount of room left available for Content
    # after taking into consideration the height of the Header and Footer
    def available_space header, footer
      trim = Tuple [@header.height + @footer.height, 0]
      size - trim
    end
  end
end
