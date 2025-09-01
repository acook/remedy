require_relative "spec_helper"
require "remedy/frame"

describe Remedy::Frame do
  let(:sizeclass) { ::Remedy::Tuple }
  let(:console_size) { sizeclass.new 6, 6 }
  subject(:f) do
    f0 = described_class.new name: "subject"
    f0.available_size = console_size
    f0.arrangement = :arbitrary
    f0.size = :fill
    f0
  end

  let(:f1) do
    f1 = described_class.new name: "f1"
    f1 << "a"
    f1.size = Tuple 3, 3
    f1.fill = ":"
    f1.valign = :center
    f1.halign = :center
    f1
  end
  let(:f2) do
    f2 = described_class.new name: "f2"
    f2 << "b"
    f2.size = Tuple 3, 3
    f2.fill = "*"
    f2.valign = :center
    f2.halign = :center
    f2
  end
  let(:f3) do
    f3 = described_class.new name: "f3"
    f3 << "c"
    f3.size = Tuple 3, 3
    f3.fill = "#"
    f3.valign = :center
    f3.halign = :center
    f3
  end

  before do
      f << f1
  end

  it "does all the things" do
    topleft      = ":::   \n:a:   \n:::   \n      \n      \n      "
    topcenter    = " :::  \n :a:  \n :::  \n      \n      \n      "
    topright     = "   :::\n   :a:\n   :::\n      \n      \n      "

    centerleft   = "      \n:::   \n:a:   \n:::   \n      \n      "
    centercenter = "      \n :::  \n :a:  \n :::  \n      \n      "
    centerright  = "      \n   :::\n   :a:\n   :::\n      \n      "

    bottomleft   = "      \n      \n      \n:::   \n:a:   \n:::   "
    bottomcenter = "      \n      \n      \n :::  \n :a:  \n :::  "
    bottomright  = "      \n      \n      \n   :::\n   :a:\n   :::"

    actual = f.to_s
    expect(actual).to eq topleft

    f1.horigin = :center
    actual = f.to_s
    expect(actual).to eq topcenter

    f1.horigin = :right
    actual = f.to_s
    expect(actual).to eq topright

    f1.vorigin = :center

    f1.horigin = :left
    actual = f.to_s
    expect(actual).to eq centerleft

    f1.horigin = :center
    actual = f.to_s
    expect(actual).to eq centercenter

    f1.horigin = :right
    actual = f.to_s
    expect(actual).to eq centerright

    f1.vorigin = :bottom

    f1.horigin = :left
    actual = f.to_s
    expect(actual).to eq bottomleft

    f1.horigin = :center
    actual = f.to_s
    expect(actual).to eq bottomcenter

    f1.horigin = :right
    actual = f.to_s
    expect(actual).to eq bottomright
  end

  context "dynamic nested frame size" do
    before do
      f1.horigin = :center
      f1.size = Tuple 0, 0.5
    end

    it "is centered" do
      expected = " :::  \n :::  \n :a:  \n :::  \n :::  \n :::  "

      actual = f.to_s
      expect(actual).to eq expected
    end
  end

  context "available_size.zero? = true" do
    before do
      f.available_size = sizeclass.zero
      f1.vorigin = :bottom
      f1.horigin = :center
    end

    context "size is Tuple" do
      before do
        f.size = console_size
      end

      it "still puts the nested frame at the bottom" do
        expected = "      \n      \n      \n :::  \n :a:  \n :::  "
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "size = :none" do
      before do
        f.size = :none
        f1.depth = 2
        f2.size = Tuple 2,1
        f << f2
      end

      it "puts the frame at the bottom of the actual space" do
        expected = "b  \n*  \n:::\n:a:\n:::"
        actual = f.to_s
        expect(actual).to eq expected
      end
    end
  end

end
