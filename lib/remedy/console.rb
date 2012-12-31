require 'remedy/console_resized'

module Remedy
  module Console
    require 'io/console'

    TIOCGWINSZ = 0x40087468

    module_function

    def input
      STDIN
    end

    def output
      STDOUT
    end

    def raw
      raw!
      result = yield
    ensure
      cooked!

      return result
    end

    def raw!
      input.echo = false
      input.raw!
    end

    def cooked!
      input.echo = true
      input.cooked!
    rescue NoMethodError
      %x{stty -raw echo 2> /dev/null}
    end

    def size
      str = [0, 0, 0, 0].pack('SSSS')
      if input.ioctl(TIOCGWINSZ, str) >= 0 then
        str.unpack('SSSS').first 2
      else
        raise UnknownConsoleSize, "Unable to get console size"
      end
    end

    def interactive?
      input.isatty
    end

    def set_console_resized_hook!
      ConsoleResized.set_console_resized_hook! do
        yield
      end
    end

    class UnknownConsoleSize < IOError; end
  end
end
