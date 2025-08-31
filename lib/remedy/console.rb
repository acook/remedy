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
    end

    def columns
      size.cols
    end
    alias_method :width, :columns

    def rows
      size.rows
    end
    alias_method :height, :rows

    def size
      return @size_override if @size_override

      str = [0, 0, 0, 0].pack('SSSS')
      if input.respond_to?(:ioctl) && input.ioctl(TIOCGWINSZ, str) >= 0 then
        Size.new str.unpack('SSSS').first 2
      else
        raise UnknownConsoleSize, "Unable to get console size"
      end
    end

    def size_override= new_size
      @size_override = new_size
    end

    def interactive?
      input.isatty
    end

    def set_console_resized_hook!
      Console::Resize.set_console_resized_hook! do |*args|
        yield(*args)
      end
    end

    class UnknownConsoleSize < IOError; end
  end
end
