require "remedy/tuple"
require "remedy/console"
require "remedy/ansi"
require "remedy/screenbuffer"
require "remedy/align"

module Remedy
  class Screen
    # Create a new Screen object.
    #
    # @note Only one Screen object should be in ***use*** at a time because a Screen instance will take over the whole terminal.
    #   But you can have multiple {Screen} instances available and swap between them on the fly.
    #   Good for having different workspaces and layouts or managing multiple applets that the user can switch to.
    #
    #   Just remember to reset the {Console.set_console_resized_hook!} for the correct Screen!
    #
    # @param auto_resize [Boolean] can be disabled if you are setting up your own console resize hook
    # @see #resize
    # @see Console.set_console_resized_hook!
    def initialize auto_resize: true, auto_redraw: true, name: object_id
      @mainframe = Frame.new name: "screen#init", parent: self
      mainframe.fill = "."
      mainframe.size = :fill
      mainframe.arrangement = :arbitrary

      Console.set_console_resized_hook! do |new_size|
        resize new_size, redraw: auto_redraw
      end if auto_resize
    end

    # @return [Frame] the {Frame} object which the {Screen} will use to draw to the terminal
    attr_accessor :mainframe
    # @return [String] the name of this {Screen} - can be anything to help you keep track of it and assist with debugging
    attr_accessor :name

    # Draw to the terminal.
    #
    # @note Any `override` will only be applied for this single draw call.
    #   If there is a {redraw} such as due to a {resize} event, it will draw the original contents.
    #   An `override` is good for testing but not general use.
    #
    #   If you want the change to persist then consider replacing the {mainframe} instead.
    #
    # @param override [Remedy::Frame,String] temporarily replace the contents of the {Screen} with this instead (until the next redraw!)
    # @return [void]
    def draw override = nil
      # FIXME: Remove this call to Console.size, it is redundant.
      mainframe.available_size = Console.size
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

    # @return [Array<Frame>] the list of top level frames inside the {mainframe}
    def frames
      mainframe.contents
    end

    # Resize the internal representation of the screen and optionally redraw the terminal.
    #
    # - If `redraw` is `false`, then `new_size` is stored in preparation for the next {draw} call.
    # - If `redraw` is `true` then after it stores the `new_size` it also immediately calls {draw}.
    #
    # If setting up your own {Console.set_console_resized_hook!} callback
    #   then you can use this as a starting point:
    #
    # ```ruby
    # Console.set_console_resized_hook! do |new_size|
    #   my_screen.resize new_size
    # end
    # ```
    #
    # @note This method is called automatically when the terminal is resized unless `auto_resize` was set to `false` on {initialize}
    #   or if the {Console.set_console_resized_hook!} is overwritten by something else (such as by another {Screen} instance).
    #
    # @param new_size [Remedy::Tuple] the updated dimensions of the terminal, which will be sent to {Screen}'s internal {mainframe} object using the {Frame#size} method
    # @param redraw [Boolean] whether the terminal should immediately be redrawn by calling {draw}
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
