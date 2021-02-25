Remedy
======

Remedy is a console interaction framework along the lines of Curses written in pure Ruby with an Object-Oriented approach and well-seperated concerns making it easy to use what you need and ignore the rest.

[![Gem Version](https://img.shields.io/gem/v/remedy.svg?style=for-the-badge)](https://rubygems.org/gems/remedy)
[![Gem Downloads](https://img.shields.io/gem/dt/remedy.svg?style=for-the-badge)](https://rubygems.org/gems/remedy)
[![Build Status](https://img.shields.io/travis/acook/remedy.svg?style=for-the-badge)](https://travis-ci.org/acook/remedy)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/acook/remedy?style=for-the-badge)](https://codeclimate.com/github/acook/remedy/maintainability)


If you have any suggestions or find any bugs, drop them in GitHub/issues so I can keep track of them. Thanks!

Installation
------------

Add this line to your application's Gemfile:

```ruby
  gem 'remedy'
```

If you're only going to use part of Remedy, you can tell Bundler to not automatically require the whole thing:

```ruby
  gem 'remedy', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remedy

Usage
-----

Remedy makes a few different classes and modules available to allow straight forward half-duplex communication with users via the console.

There are objects for input as well as output, including low level console keystroke reads and screen drawing.

### Interaction

The `Interaction` object wraps raw keyboard reads and streamlines some aspects of accepting keyboard input.

```ruby
  include Remedy
  user_input = Interaction.new

  user_input.loop do |key|
    puts key
  end
```

### Viewport

`Viewport` is the object that draws on your screen, you can give it any compatible `Remedy::Partial` object, or something that responds like one.

```ruby
  include Remedy
  joke = Content.new
  joke << "Q: What's the difference between a duck?"
  joke << "A: Purple, because ice cream has no bones!"

  screen = Viewport.new
  screen.draw joke
```

`Remedy::Partial` has the subclasses `Header`, `Footer`, and `Content`.

You can use the above classes to divide your Views into 3 seperate pieces. Content will be truncated as needed to accomodate the header and footer and the dimensions of the console. You can also specify the cursor/scroll position of the content being drawn, and when specifying headers or footers, you must.

```ruby
  include Remedy
  title = Header.new
  title << "Someone Said These Were Good"

  jokes = Content.new
  jokes << %q{1. A woman gets on a bus with her baby. The bus driver says: 'Ugh, that's the ugliest baby I've ever seen!' The woman walks to the rear of the bus and sits down, fuming. She says to a man next to her: 'The driver just insulted me!' The man says: 'You go up there and tell him off. Go on, I'll hold your monkey for you.'}
  jokes << %q{2. I went to the zoo the other day, there was only one dog in it, it was a shitzu.}

  disclaimer = Footer.new
  disclaimer << "According to a survey they were funny. I didn't make them."

  screen = Viewport.new
  screen.draw jokes, Size.new(0,0), title, disclaimer
```

### Console

If you want easy access to some lower level console commands, you can use `Console`.

The most interesting function in my opinion is the callback that gets triggered when the user resizes the console window.

```ruby
  include Remedy

  screen = Viewport.new
  notice = Content.new
  notice << "You just resized your screen!\n\nBrilliant!"

  Console.set_console_resized_hook! do
    screen.draw notice
  end
```

Remedy in the Wild
------------------

Remedy was originaly written for my own console-based game which was sort of like Dwarf Fortress. Most of the project files were lost, but since Remedy was extracted from it and open-sourced it has lived on.

Here are a couple of projects that use many of Remedy's features:
- A multiplayer Yahtzee for web and console: [YahtzeeGame](https://github.com/ProgrammingPractice/YahtzeeGame)
- Twitter/RSS/Facebook reader: [noizee](https://github.com/acook/noizee)

Check them out for some full examples of usage!

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

