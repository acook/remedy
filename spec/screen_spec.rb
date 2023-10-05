require_relative "spec_helper"
require "remedy/screen"
require "stringio"

describe Remedy::Screen do
  subject(:s){ described_class.new auto_resize: false }
  let(:console){ ::Remedy::Console }
  let(:size){ Tuple 20, 40 }
  let(:size_override){ Tuple 20, 40 }
  let(:stringio){ StringIO.new.tap{|sio| def sio.ioctl(magic, str); str = [20, 40, 0, 0].pack('SSSS'); 1; end } }

  before(:each) do
    console.input = stringio
    console.output = stringio
    console.size_override = size_override
    s.resized size
    stringio.string = ""
  end

  after(:each) do
    console.input = $stdin
    console.output = $stdout
    console.size_override = nil
  end

  describe "#draw" do
    context "tiny 2x2 screen" do
      let(:size){ Tuple 2, 2 }

      it "writes the buffer to the output" do
        expected = "\e[H\e[J..\e[1B\e[0G..".inspect[1..-2]

        s.draw

        actual = stringio.string.inspect[1..-2]
        expect(actual).to eq expected
      end
    end

    context "small 3x20 screen" do
      let(:size){ Tuple 3, 20 }

      it "can display single objects with the override parameter" do
        expected = "\\e[H\\e[J....................\\e[1B\\e[0G....hello, world!...\\e[1B\\e[0G...................."
        value = "hello, world!"

        s.draw ::Remedy::Partial.new [value]

        actual = stringio.string.inspect[1..-2]

        expect(actual).to match value
        expect(actual).to eq expected
      end
    end
  end
end
