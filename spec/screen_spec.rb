require_relative "spec_helper"
require "remedy/screen"
require "remedy/frame"
require "remedy/partial"
require "stringio"

describe Remedy::Screen do
  subject(:s){ described_class.new auto_resize: false }
  let(:console){ ::Remedy::Console }
  let(:size){ Tuple 20, 40 }
  let(:size_override){ Tuple 20, 40 }

  before(:each) do
    console.size_override = size_override
  end

  context "captured STDIO" do
    let(:stringio){ StringIO.new.tap{|sio| def sio.ioctl(magic, str); str = [20, 40, 0, 0].pack('SSSS'); 1; end } }

    before(:each) do
      console.input = stringio
      console.output = stringio
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
          expected = "\\e[H\\e[J....................\\e[1B\\e[0G...hello, world!....\\e[1B\\e[0G...................."
          value = "hello, world!"

          s.draw ::Remedy::Partial.new [value]

          actual = stringio.string.inspect[1..-2]

          expect(actual).to match value
          expect(actual).to eq expected
        end
      end
    end
  end

  describe "#frames" do
    let(:size){ Tuple 3, 5 }
    let(:size_override){ size }

    let(:frame) do
      f = ::Remedy::Frame.new
      f.contents << "foo"
      f.contents << "bar\nbaz"
      f
    end

    it "gets the list of frames" do
      expected = [frame]

      s.frames << frame

      actual = s.frames
      expect(actual).to eq expected
    end

    it "can add a single frame to the screen" do
      expected = "foo..\nbar..\nbaz.."
      s.frames << frame
      actual = s.to_s
      expect(actual).to eq expected
    end
  end

  describe "#to_s" do
    let(:size_override){ Tuple 5, 11 }

    let(:frame) do
      f = ::Remedy::Frame.new
      f.contents << "foo"
      f.contents << "bar\nbaz"
      f.vorigin = :center
      f.horigin = :center
      f.size = :none
      f
    end

    it "attaches frames where they specify" do
      expected = [
        "           ",
        "    foo    ",
        "    bar    ",
        "    baz    ",
        "           "
      ].join ?\n

      s.buffer.fill = " "
      s.frames << frame
      actual = s.to_s

      expect(actual).to eq expected
    end
  end
end
