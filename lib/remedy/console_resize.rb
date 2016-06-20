module Remedy; module Console; module Resize
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

  def set_console_resized_hook!
    @resize_count = 0

    command = lambda { |x|
      resizing!
      sleep 0.25

      if resized? then
        yield
      end

      resized!
    }

    Signal.trap 'SIGWINCH', command
  end

  def default_console_resized_hook!
    Signal.trap 'SIGWINCH', 'DEFAULT'
  end
end; end; end
