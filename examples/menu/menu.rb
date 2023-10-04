require 'bundler'
Bundler.require
require 'remedy'

class Menu
  include Remedy

  def initialize
    @viewport = Viewport.new
  end

  # will do basic setup and then loop over user input
  def listen
    # if the user resizes the screen we redraw it to fit the new dimensions
    Console.set_console_resized_hook! do |size|
      draw
    end

    # create an interaction object to handle user input
    interaction = Interaction.new

    # call draw here because interaction blocks until it gets input
    draw

    # loop over user input (individual keypresses)
    interaction.loop do |key|
      @last_key = key
      if key == "q" then
        interaction.quit!
      end
      draw
    end
  end

  # this tells the Viewport to draw to the screen
  def draw
    @viewport.draw content, Size([0,0]), header, footer
  end

  # this is the body of our menu, it will be squished if the terminal is too small
  def content
    # this creates a new content every time we draw
    # you may want to only create a new content/header/footer when they change
    # or create your own Partial subclass
    c = Partial.new
    c << <<-CONTENT

    1. Do the thing
    2. Do other thing
    3. Do the third thing
    Q. Quit the thing

    CONTENT
    c
  end

  # headers are displayed the top of the viewport
  def header
    Partial.new << "The time is: #{Time.now}"
  end

  # footers are displayed the bottom of the viewport
  def footer
    Partial.new << "Screen size: #{Console.size} You pressed: #{@last_key}"
  end
end

# display menu and accept user input
Menu.new.listen
