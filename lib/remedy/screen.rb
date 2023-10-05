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
    # @see #resized
    # @see Console.set_console_resized_hook!
    def initialize auto_resize: true
      @buffer = Screenbuffer.new Console.size, fill: "."

      Console.set_console_resized_hook! do |new_size|
        resized new_size
      end if auto_resize
    end
    attr_accessor :buffer

    # Draw the buffer to the console using raw output.
    # @return [void]
    def draw override = nil
      if override then
        Align.buffer_center override, buffer
      end
      ANSI.screen.safe_reset!
      Console.output << buffer.to_ansi
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
    #   my_screen.resized new_size
    # end
    # ```
    #
    # @param new_size [Remedy::Tuple] the new size of the terminal
    # @return [void]
    def resized new_size
      buffer.size = new_size
      draw
    end
  end
end
