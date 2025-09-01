require 'remedy/keyboard'
require 'remedy/ansi'

module Remedy
  class Interaction
    # @param message [String] the message to display to the user for the {loop} and {get_key} prompts
    def initialize message = nil
      @message = message
    end

    attr_accessor :message

    # A simple way to ask a user to confirm an action.
    # @return [Boolean] `true` if the use presses `y`, otherwise `false`
    def confirm message = 'Confirm?'
      ANSI.cursor.home!
      ANSI.command.clear_line!

      print message, ' y/n '
      if Keyboard.get === :y then
        yield if block_given?
        true
      else
        false
      end
    end

    # Placeholder quit confirmation 'dialog' for use during initial development of your application.
    #
    # Clears the screen and restores the cursor visibility before exiting.
    #
    # Also demonstrates the usage of {confirm}.
    def quit!
      confirm 'Are you sure you want to quit? You will lose everything. :(' do
        ANSI.cursor.home!
        ANSI.command.clear_down!
        ANSI.cursor.show!

        puts " -- Bye!"
        exit
      end
    end

    # Helper to launch debugger without crashing if it is missing.
    def debug!
      require 'pry'
      binding.pry
    end

    def display key
      ANSI.command.clear_line!
      print " -- You pressed: #{key.inspect}"
    end

    # A quick-and-dirty way to integrate {Remedy} and interactivity into your Ruby command line application.
    # This method hides the cursor and stops the terminal from echoing what the user types.
    #
    # Provided interactions:
    #
    #   - Responds to control-q by calling {quit!}.
    #   - Responds to control-c by raising {Keyboard::ControlC} (can be disabled by calling {Keyboard.dont_raise_on_control_c!} in your block)
    #   - Responds to control-d by trying to launch a debug console.
    #
    # Put your key handling logic in a block passed into `loop`.
    # To exit the loop programmatically call `break`.
    #
    # Demonstration:
    # ```ruby
    # require 'remedy'
    # include Remedy
    #
    # def start
    #   puts "Press left and right to move, control-c or 'q' to quit!"
    #   i = Interaction.new
    #
    #   i.loop do |key|
    #     if key.name == :left
    #       my_player.move_left
    #     elsif key.name == :right
    #       my_player.move_right
    #     elsif key.name == :q
    #       break
    #     end
    #   end
    #
    #   puts "Thanks for playing!"
    # rescue Keyboard::ControlC
    #   puts "Quitting: control-c pressed!"
    # end
    # ```
    #
    # @note If you called {initialize} with a `message` parameter, that same `message` will be displayed ***each time*** the loop starts over
    #   to ensure that the user can always see the prompt.
    #
    # @yieldparam [Key] key the {Key} pressed by the user as an object
    # @return whatever you pass to `break`, otherwise it doesn't return at all
    # @raise [Keyboard::ControlC] if the user presses control-c
    def loop
      Keyboard.raise_on_control_c!

      super do
        print " -- #{message}" if message

        ANSI.cursor.hide!
        key = Keyboard.get

        if key == ?\C-q then
          display key
          quit!
        elsif key == ?\C-d and defined? Pry then
          display key
          debug!
        end

        yield key
      end
    end

    # @note If you called {initialize} with a `message` parameter, that same `message` will be displayed as a prompt.
    #
    # Get a single key press from the user.
    #
    # @return [Key] the key the user pressed
    def get_key
      print " -- #{message}" if message

      ANSI.cursor.hide!
      Keyboard.get
    end
  end
end
