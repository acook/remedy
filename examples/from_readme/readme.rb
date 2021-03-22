require 'bundler'
Bundler.require
require 'remedy'

include Remedy

screen = Viewport.new

notice = Content.new
notice << "You just resized your screen!\n\nBrilliant!"

Console.set_console_resized_hook! do
  screen.draw notice
end

user_input = Interaction.new "press any key to continue"

joke = Content.new
joke << "Q: What's the difference between a duck?"
joke << "A: Purple, because ice cream has no bones!"

screen.draw joke

user_input.get_key

title = Header.new
title << "Someone Said These Were Good"

jokes = Content.new
jokes << %q{1. A woman gets on a bus with her baby. The bus driver says: 'Ugh, that's the ugliest baby I've ever seen!' The woman walks to the rear of the bus and sits down, fuming. She says to a man next to her: 'The driver just insulted me!' The man says: 'You go up there and tell him off. Go on, I'll hold your monkey for you.'}
jokes << %q{2. I went to the zoo the other day, there was only one dog in it, it was a shitzu.}

disclaimer = Footer.new
disclaimer << "According to a survey they were funny. I didn't make them."

screen.draw jokes, Size.new(0,0), title, disclaimer

user_input.get_key

ANSI.cursor.next_line!
loop_demo = Interaction.new "press q to exit, or any other key to display that key's name\n"
loop_demo.loop do |key|
  ANSI.cursor.beginning_of_line!
  ANSI.command.clear_line!
  puts key
  break if key == ?q
end

Console.cooked!
ANSI.cursor.show!
