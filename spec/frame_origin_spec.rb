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

  describe "horigin = :center" do
    before do
      f1.horigin = :center
      f << f1
    end

    it "is centered" do
      expected = " :::  \n :a:  \n :::  \n      \n      \n      "

      actual = f.to_s
      expect(actual).to eq expected
    end

    context "dynamic nested frame size" do
      before do
        f1.size = Tuple 0, 0.5
      end

      it "is centered" do
        expected = " :::  \n :::  \n :a:  \n :::  \n :::  \n :::  "

        actual = f.to_s
        expect(actual).to eq expected
      end
    end
  end

  describe "vorigin = :bottom" do
    before do
      f.arrangement = :arbitrary
      f.reset!

      f1.size = Tuple 3, 3

      f1.horigin = :center
      f1.vorigin = :bottom
      f << f1
    end

    it "puts the nested frame at the bottom" do
      expected = "      \n      \n      \n :::  \n :a:  \n :::  "
      actual = f.to_s
      expect(actual).to eq expected
    end

    context "available_size.zero? = true" do
      before do
        f.available_size = sizeclass.zero
        f.size = sizeclass.new 6, 6
      end

      it "still puts the nested frame at the bottom" do
        expected = "      \n      \n      \n :::  \n :a:  \n :::  "
        actual = f.to_s
        expect(actual).to eq expected
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

    context "horigin = :center" do
      before do
        f.size = Tuple 5, 5
        f.available_size = Tuple 5, 5
        f.arrangement = :arbitrary
        f.reset!

        f1.horigin = :center
        f << f1
      end

      it "parent frame places it in the middle" do
        expected = "     \n     \n ::: \n :a: \n ::: "
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "horigin = :right" do
      before do
        f.size = Tuple 5, 5
        f.available_size = Tuple 5, 5
        f.arrangement = :arbitrary
        f.reset!

        f1.horigin = :right
        f << f1
      end

      it "parent frame places it to the right" do
        expected = "     \n     \n  :::\n  :a:\n  :::"
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

  end
end
