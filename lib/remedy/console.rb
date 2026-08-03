require 'remedy/console_resize'

module Remedy
  module Console
    require 'io/console'

    TIOCGWINSZ = case RbConfig::CONFIG['host_os']
      when /darwin|mac os/
        0x40087468
      when /linux/
        0x5413
      else
        0x00
      end

    module_function

    def input
      @input ||= $stdin
    end

    def output
      @output ||= $stdout
    end

    def input= new_input
      @input = new_input
    end

    def output= new_output
      @output = new_output
    end

    # Put the terminal into raw mode and evaluates the provided block before returning to cooked mode.
    #
    # @yieldparams [Tuple] (see size)
    def raw
      raw!
      result = yield
    ensure
      cooked!
      return result
    end

    # Sets raw mode on the terminal and disables keypress echo.
    def raw!
      input.echo = false
      input.raw!
    end

    # Sets cooked mode on the terminal enabled keypress echo.
    def cooked!
      input.echo = true
      input.cooked!
    end

    # @return [Numeric] the number of columns available in the terminal
    def columns
      size.cols
    end
    alias_method :width, :columns

    # @return [Numeric] the number of rows available in the terminal
    def rows
      size.rows
    end
    alias_method :height, :rows

    # @return [Tuple] the size of the terminal in rows and columns
    def size
      return @size_override if @size_override

      str = [0, 0, 0, 0].pack('SSSS')
      if input.respond_to?(:ioctl) && input.ioctl(TIOCGWINSZ, str) >= 0 then
        Tuple.new str.unpack('SSSS').first 2
      else
        raise UnknownConsoleSize, "Unable to get console size"
      end
    end

    # @note Useful for testing but should not be used in normal operation without good cause.
    #   Cannot change the actual size of the terminal.
    def size_override= new_size
      @size_override = new_size
    end

    # Detect if the terminal is interactive or if the program is being run in a pipe.
    def interactive?
      input.isatty
    end

    # @note One of the most powerful methods in the whole library for building robust TUIs!
    #
    # Pass a block to this method to perform an action when the terminal is resized. Typically this will be to redraw the contents to fit the new size, such as with {Screen.draw}.
    def set_console_resized_hook!
      Console::Resize.set_console_resized_hook! do |*args|
        yield(*args)
      end
    end

    class UnknownConsoleSize < IOError; end
  end
end
