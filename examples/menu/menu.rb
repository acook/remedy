require 'remedy'

class Menu
  include Remedy

  def listen
    Console.set_console_resized_hook! do
      display
    end

    interaction = Interaction.new

    display
    interaction.loop do |key|
      handle key, interaction
      display
    end
  end

  def handle key, interaction
    @last_key = key
    if key == "q" then
      interaction.quit!
    end
  end

  def display
    Viewport.new.draw content, Size([0,0]), header, footer
  end

  def content
    Partial.new.tap{|c| c << <<-CONTENT

    1. Do the thing
    2. Do other thing
    3. Do the third thing
    Q. Quit the thing

    CONTENT
    }
  end

  def header
    Header.new << "The time is: #{Time.now}"
  end

  def footer
    Footer.new << "You pressed: #{@last_key}"
  end
end

Menu.new.listen
