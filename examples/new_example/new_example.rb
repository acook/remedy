require "remedy"
require "remedy/screen"
require "remedy/frame"

class Example
  include Remedy

  def self.cleanup
    ANSI.screen.safe_reset!
    Console.cooked!
    ANSI.cursor.show!
  end

  def setup
    trap "SIGINT" do
      Example.cleanup
      warn "Caught control-c interupt!"
      exit 130
    end
  end

  def run
    screen = Screen.new name: "Main Screen"
    screen.frames << lsidebar
    screen.frames << rsidebar
    screen.frames << content
    screen.frames << window
    screen.frames << modal

    screen.draw

    Interaction.new.get_key
  ensure
    self.class.cleanup
  end

  def lsidebar
    f = Frame.new name: "lsidebar"
    f.horigin = :left
    f.vorigin = :center
    f.halign = :left
    f.valign = :center
    f.size   = Tuple 0, 0.25
    f.fill   = "="
    f
  end

  def rsidebar
    f = Frame.new name: "rsidebar"
    f.horigin = :right
    f.vorigin = :center
    f.halign = :left
    f.valign = :center
    f.size   = Tuple 0, 0.25
    f.fill   = "+"
    f
  end

  def content
    f = Frame.new name: "content"
    f.horigin = :center
    f.vorigin = :center
    f.halign = :left
    f.valign = :top
    f.size   = Tuple 0, 0.5
    f.fill   = ":"
    f.arrangement = :columnar
    f << l_col
    f << r_col
    f
  end

  def l_col
    f = Frame.new name: "l_col"
    f << "foo"
    f.halign = :left
    f.valign = :top
    f.fill = "-"
    f.size = Tuple 5, 5
    f
  end

  def r_col
    f = Frame.new name: "r_col"
    f << "bar"
    f.halign = :right
    f.valign = :bottom
    f.fill = "|"
    f.size = Tuple 5, 5
    f
  end

  def modal
    f = Frame.new name: "modal"
    f.horigin = :center
    f.vorigin = :center
    f.halign = :center
    f.valign = :center
    f.size   = Tuple 3, 15
    f.fill   = "#"

    msg = "hello, world!"
    f << msg
    f
  end

  def window
    f = Frame.new name: "window"
    f.arrangement = :arbitrary
    f.offset = Tuple 5, 5
    f.size   = Tuple 10, 20
    f.fill = "'"
    f << titlebar
    f << statusbar
    f
  end

  def titlebar
    f = Frame.new name: "titlebar"
    f.vorigin = :top
    f.halign = :center
    # FIXME: zero sizes don't yet work for nested frames
    #f.size = Tuple 1, 0
    f.size = Tuple 1, 20
    f.fill = "━"
    f << "┫ title ┣"
    f
  end

  def statusbar
    f = Frame.new name: "statusbar"
    f.vorigin = :bottom
    f.horigin = :left
    f.halign = :center
    f.depth = 3
    # FIXME: zero sizes don't yet work for nested frames
    #f.size = Tuple 1, 0
    f.size = Tuple 1, 20
    f.fill = "┄"
    f << Time.now.to_s
    f
  end
end

Example.new.run
