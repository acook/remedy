require_relative "spec_helper"
require "remedy/viewport"

describe Remedy::Viewport do
  let(:console){ ::Remedy::Console }
  let(:size_override){ Tuple 20, 40 }
  let(:stringio){ StringIO.new }

  before(:each) do
    console.input = stringio
    console.output = stringio
    console.size_override = size_override
  end

  after(:each) do
    console.input = $stdin
    console.output = $stdout
    console.size_override = nil
  end

  it 'should be able to execute the example code from the readme' do
    expected = "\\e[H\\e[JQ: What's the difference between a duck?\\e[1B\\e[0GA: Purple, because ice cream has no bone\\e[1B\\e[0G"

    joke = ::Remedy::Partial.new
    joke << "Q: What's the difference between a duck?"
    joke << "A: Purple, because ice cream has no bones!"

    screen = ::Remedy::Viewport.new
    screen.draw joke

    actual = stringio.string.inspect[1..-2]
    expect(actual).to eq expected
  end
end
