module Remedy; module Console;
# The Resize class exists just to manage the event of the terminal's size changing
# and exists mostly as an implementation detail.
#
# @note Application developers shouldn't need to interact with {Resize} directly, instead use the {Console.when_resized} method.
#
# ## What it Does
#
# The magic of this class is that it controls how the callbacks are fired off while still being responsive.
# Resizing of terminal emulator windows tends to happen by dragging them.
# This fires off dozens - or even *hundreds* - of resizing events all at once.
#
# If unmanaged this would cause an application to try to handle the callbacks in a random order,
# each one interupting the other at arbitrary points in the code, causing the display to become corrupted,
# or even crash the application entirely.
#
# A common strategy for migitating this problem is to reset a timer each time the callback is run
# and when the timer runs out only then will it perform any redrawing logic.
# This works well enough but timers require constant updates and this set delay means that resizing can feel unresponsive.
#
# What this class does is increment a simple counter when the callback starts and decrement it when it finishes.
# In between it checks if the number is less than or equal to 1, if so, it runs the resize logic.
# In a single-threaded Ruby environment, this is sufficient to ensure that the application remains stable in all of my testing.
module Resize
  module_function

  def resizing?
    @resize_count > 0
  end

  def resizing!
    @resize_count = @resize_count < 1 ? 1 : @resize_count + 1
  end

  def resized?
    @resize_count <= 1
  end

  def resized!
    @resize_count = @resize_count < 0 ? 0 : @resize_count - 1
  end

  def resizer?
    @resize_count == 1
  end

  # @see Console.when_resized
  def set_console_resized_hook!
    @resize_count = 0

    Signal.trap 'SIGWINCH' do
      resizing!

      if resized? then
        begin
          yield Console.size
        rescue Exception => ex
          # Ruby will eat *any* errors inside a trap,
          # so we need to expose them for debuggability
          p ex
        end
      end

    ensure
      resized!
    end
  end

  def default_console_resized_hook!
    Signal.trap 'SIGWINCH', 'DEFAULT'
  end
end; end; end
