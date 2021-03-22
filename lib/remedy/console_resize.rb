module Remedy; module Console; module Resize
  module_function

  # this needs to be a global object since we can only trap SIGWINCH for 1 terminal per process AFAIK
  # using module_function because there's not a lot of clear ways to implement this pattern in Ruby

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

  def set_hook!
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

      resized!
    end
  end

  def unset_hook!
    Signal.trap 'SIGWINCH', 'DEFAULT'
  end
end; end; end
