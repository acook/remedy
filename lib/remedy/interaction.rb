require 'remedy/keyboard'
require 'remedy/ansi'

class Interaction
  def initialize message = nil
    @message = message
  end

  attr_accessor :message

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

  def quit!
    confirm 'Are you sure you want to quit? You will lose everything. :(' do
      ANSI.cursor.home!
      ANSI.command.clear_down!
      ANSI.cursor.show!

      puts " -- Bye!"
      exit
    end
  end

  def debug!
    require 'pry'
    binding.pry
  end

  def display key
    ANSI.command.clear_line!
    print " -- You pressed: #{key.inspect}"
  end

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
end
