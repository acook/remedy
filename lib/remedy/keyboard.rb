require 'remedy/console'
require 'remedy/key'

module Remedy
  module Keyboard
    module_function

    def get
      parse raw_get
    end

    def raw_get
      Console.raw do
        input = STDIN.getc.chr

        if input == "\e" then
          input << STDIN.read_nonblock(3) rescue nil
          input << STDIN.read_nonblock(2) rescue nil
        end

        input
      end
    end

    def parse sequence
      key = Key.new sequence

      if raise_on_control_c? && key.control_c? then
        raise ControlC, "User pressed Control-C"
      elsif key.recognized? then
        key
      elsif raise_on_unrecognized_key? then
        raise UnrecognizedInput, %Q{Unknown key or byte sequence: "#{sequence}" : #{key.inspect}}
      else
        key
      end
    end

    def raise_on_unrecognized_key?
      @raise_on_unrecognized_key
    end

    def raise_on_unrecognized_key!
      @raise_on_unrecognized_key = true
    end

    def dont_raise_on_unrecognized_key!
      @raise_on_unrecognized_key = false
    end

    def raise_on_control_c?
      @raise_on_control_c
    end

    def raise_on_control_c!
      @raise_on_control_c = true
    end

    def dont_raise_on_control_c!
      @raise_on_control_c = false
    end

    class ControlC < Interrupt; end
    class UnrecognizedInput < IOError; end
  end
end
