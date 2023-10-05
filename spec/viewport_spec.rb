require_relative 'spec_helper'
require 'remedy/viewport'

describe Remedy::Viewport do
  it 'should be able to execute the example code from the readme' do
    @stdout = $stdout
    joke = ::Remedy::Partial.new
    joke << "Q: What's the difference between a duck?"
    joke << "A: Purple, because ice cream has no bones!"

    screen = ::Remedy::Viewport.new
    sio = StringIO.new
    $stdout = sio
    screen.draw joke unless ENV['CI']
    expect(sio.string).to include("ice cream")
  ensure
    $stdout = @stdout
  end
end
