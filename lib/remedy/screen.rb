require "remedy/tuple"
require "remedy/console"
require "remedy/ansi"
require "remedy/screenbuffer"
require "remedy/align"

module Remedy
  class Screen
    # Create a new Screen object.
    #
    # Only one Screen object should be in use at a time
    #   because they talk directly to the raw terminal.
    #   But feel free to have multiple available and swap between them,
    #   Might be good for having multiple workspaces.
    #
    # @param auto_resize [Boolean] can be disabled if you are setting up your own console resize hook
    # @see #resize
    # @see Console.set_console_resized_hook!
    def initialize auto_resize: true, auto_redraw: true
      @mainframe = Frame.new name: "screen#init", parent: self
      mainframe.fill = "."
      mainframe.size = :fill
      mainframe.arrangement = :arbitrary

      Console.set_console_resized_hook! do |new_size|
        resize new_size, redraw: auto_redraw
      end if auto_resize
    end
    attr_accessor :mainframe

    # Draw the buffer to the console using raw output.
    # @param override [Remedy::Frame,String] temporarily replace the contents with this instead (until the next redraw!)
    # @return [void]
    def draw override = nil
      if override then
        f = Frame.new name: "screen#draw/override", parent: self, content: override
        f.size = :fill
        f.fill = "."
        f.available_size = mainframe.available_size
        f.halign = :center
        f.valign = :center
        frame = f
      else
        refresh
        frame = mainframe
      end
      ANSI.screen.safe_reset!
      Console.output << frame.to_ansi
    end

    def frames
      mainframe.contents
    end

    # This sets the new screen size and rebuilds the buffer before redrawing it.
    #
    # Called automatically unless `auto_resize` was set to `false`,
    #   or if the console resized hook was changed to something else.
    #
    # If setting up your own `Console.set_console_resized_hook!` callback
    #   then you can use this as a starting point:
    #
    # ```ruby
    # Console.set_console_resized_hook! do |new_size|
    #   my_screen.resize new_size
    # end
    # ```
    #
    # @param new_size [Remedy::Tuple] the new size of the terminal
    # @return [void]
    def resize new_size, redraw: true
      mainframe.available_size = new_size
      draw if redraw
    end

    def to_a
      refresh
      mainframe.to_a
    end

    def to_s
      refresh
      mainframe.to_s
    end

    def to_ansi
      refresh
      mainframe.to_ansi
    end

    def refresh
      mainframe.compile_contents
    end
  end
end
