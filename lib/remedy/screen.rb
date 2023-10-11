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
      @buffer = Screenbuffer.new Console.size, fill: ".", parent: self, name: "screen#init"

      Console.set_console_resized_hook! do |new_size|
        resize new_size, redraw: auto_redraw
      end if auto_resize
    end
    attr_accessor :buffer

    # Draw the buffer to the console using raw output.
    # @param override [Remedy::Frame,String] temporarily replace the contents with this instead (until the next redraw!)
    # @return [void]
    def draw override = nil
      if override then
        Align.hv_center override, buffer
      else
        refresh_buffer
      end
      ANSI.screen.safe_reset!
      Console.output << buffer.to_ansi
    end

    def frames
      @frames ||= Array.new
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
      buffer.size = new_size
      draw if redraw
    end

    def to_a
      refresh_buffer
      buffer.to_a
    end

    def to_s
      refresh_buffer
      buffer.to_s
    end

    def to_ansi
      refresh_buffer
      buffer.to_ansi
    end

    def refresh_buffer
      buffer.reset!
      populate_buffer
    end

    def populate_buffer
      frames.sort_by(&:depth).each do |frame|
        frame.available_size = buffer.size
        content = frame.compile_contents
        fsize = frame.computed_size

        case frame.vorigin
        when :top
          voffset = 0
        when :center
          voffset = Align.mido fsize.height, buffer.size.height
        when :bottom
          voffset = buffer.size.height - fsize.height
        else
          raise "Unknown vorigin:#{frame.vorigin}"
        end

        case frame.horigin
        when :left
          hoffset = 0
        when :center
          hoffset = Align.mido fsize.width, buffer.size.width
        when :right
          hoffset = buffer.size.width - fsize.width
        else
          raise "Unknown horigin:#{frame.horigin}"
        end

        voffset += frame.offset.height
        hoffset += frame.offset.width

        buffer[voffset,hoffset] = content
      end
    end
  end
end
