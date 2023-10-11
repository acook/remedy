require_relative "spec_helper"
require "remedy/screen"
require "remedy/frame"
require "remedy/partial"
require "stringio"

describe Remedy::Screen do
  subject(:s){ described_class.new auto_resize: false }
  let(:console){ ::Remedy::Console }
  let(:fclass) { ::Remedy::Frame }
  let(:size){ Tuple 20, 40 }
  let(:size_override){ Tuple 20, 40 }
  let(:frame) do
    f = fclass.new
    f << "foo"
    f << "bar\nbaz"
    f.vorigin = :center
    f.horigin = :center
    f.valign = :center
    f.halign = :center
    f.size = :none
    f
  end

  before(:each) do
    console.size_override = size_override
  end

  context "captured STDIO" do
    let(:stringio){ StringIO.new.tap{|sio| def sio.ioctl(magic, str); str = [20, 40, 0, 0].pack('SSSS'); 1; end } }

    before(:each) do
      console.input = stringio
      console.output = stringio
      s.resize size, redraw: true # why does this need to be set to true??
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
      f = fclass.new
      f << "foo"
      f << "bar\nbaz"
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

  describe "#resize" do
    let(:new_size_override){ Tuple 5, 9 }

    before do
      frame.size = Tuple(0, 0.5)
      frame.fill = "."
    end

    it "resizes internal frames" do
      # This is a very surface level test which did not detect a bug caused by
      #   Tuple#dup, but still demonstrates the basics
      expected = [
        "  ....   ",
        "  foo.   ",
        "  bar.   ",
        "  baz.   ",
        "  ....   "
      ].join ?\n

      s.buffer.fill = " "
      s.frames << frame
      s.resize new_size_override, redraw: false
      actual = s.to_s

      expect(actual).to eq expected
    end
  end

  describe "offset frames" do
    let(:size_override){ Tuple 5, 9 }

    before do
      frame.vorigin = :bottom
      frame.horigin = :right
      frame.halign  = :center
      frame.valign  = :center
      frame.offset = Tuple -1, -2
      frame.size = Tuple(4, 0.5)
      frame.fill = "."
    end

    it "moves the frame away from the point of origin" do

      expected = [
        "   foo.  ",
        "   bar.  ",
        "   baz.  ",
        "   ....  ",
        "         "
      ].join ?\n

      s.buffer.fill = " "
      s.frames << frame
      actual = s.to_s

      expect(actual).to eq expected
    end
  end

  describe "layering" do
    let(:size_override){ Tuple 7, 7 }
    let(:f1) do
      f1 = fclass.new
      f1.valign = :center
      f1.halign = :center
      f1 << "a"
      f1.size = Tuple 3, 3
      f1.fill = ":"
      f1
    end
    let(:f2) do
      f2 = fclass.new
      f2.valign = :center
      f2.halign = :center
      f2 << "b"
      f2.size = Tuple 3, 3
      f2.offset = Tuple 2, 2
      f2.fill = "*"
      f2.depth = 1
      f2
    end
    let(:f3) do
      f3 = fclass.new
      f3.valign = :center
      f3.halign = :center
      f3 << "c"
      f3.size = Tuple 3, 3
      f3.offset = Tuple 4, 4
      f3.fill = "#"
      f3.depth = 2
      f3
    end

    before do
      s.frames.clear
      s.frames << f1
      s.frames << f2
      s.frames << f3
    end

    it "places frames on top of each other according to their depth and order" do
      expected = [
        ":::....",
        ":a:....",
        "::***..",
        "..*b*..",
        "..**###",
        "....#c#",
        "....###"
      ].join ?\n

      actual = s.to_s
      expect(actual).to eq expected
    end

    context "f2.depth = 3" do
      before do
        f2.depth = 3
      end

      it "places frames on top of each other according to their depth and order" do
        expected = [
          ":::....",
          ":a:....",
          "::***..",
          "..*b*..",
          "..***##",
          "....#c#",
          "....###"
        ].join ?\n

        actual = s.to_s
        expect(actual).to eq expected
      end
    end
  end
end
