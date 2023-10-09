require_relative "spec_helper"
require "remedy/frame"
require "remedy/partial"

describe Remedy::Frame do
  subject(:f){ described_class.new name: "subject" }

  describe "#content_size" do
    it "returns a Tuple of the contents dimensions" do
      expected = Tuple 2, 4
      f << "1234"
      f << "567"

      actual = f.content_size
      expect(actual).to eq expected
    end
  end

  describe "#to_s" do
    it "returns a string" do
      expected = String
      actual = f.to_s.class
      expect(actual).to eq expected
    end
  end

  describe "#to_a" do
    it "returns an array" do
      expected = Array
      actual = f.to_a.class
      expect(actual).to eq expected
    end
  end

  describe "#compile_contents" do
    it "compiles the contents of a single string" do
      expected = "foo"
      content = "foo"
      f << content
      actual = f.to_s
      expect(actual).to eq expected
    end

    it "compiles the contents of multiple strings" do
      expected = "foo\nbar\nbaz"
      f << "foo"
      f << "bar"
      f << "baz"
      actual = f.to_s
      expect(actual).to eq expected
    end

    it "compiles the contents of partials" do
      expected = "foo\nbar"
      f << "foo"
      f << ::Remedy::Partial.new(["bar"])
      actual = f.to_s
      expect(actual).to eq expected
    end
  end

  describe "size and alignment" do

    context "size = Tuple" do
      before do
        f.size = Tuple 5, 5
        f.available_size = Tuple 7, 7

        f << "foo"
        f << "bar"
        f << "baz"
      end

      context "halign = :left" do
        before do
          f.halign = :left
        end

        it "fills and aligns contents to the left" do
          expected = "foo  \nbar  \nbaz  \n     \n     "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end
    end

    context "size = :fill" do
      before do
        f.size = :fill
        f.available_size = Tuple 6, 6

        f << "foo"
        f << "bar"
        f << "baz"
      end

      context "halign = :left" do
        before do
          f.halign = :left
        end

        it "fills and aligns contents to the left" do
          expected = "foo   \nbar   \nbaz   \n      \n      \n      "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end

      context "halign = :right" do
        before do
          f.halign = :right
        end

        it "fills and aligns contents to the right" do
          expected = "   foo\n   bar\n   baz\n      \n      \n      "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end

      context "halign = :center" do
        before do
          f.halign = :center
        end

        it "fills and aligns contents to the center" do
          expected = " foo  \n bar  \n baz  \n      \n      \n      "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end
    end

    context "size = :auto" do
      before do
        f.size = :auto
        f.available_size = Tuple 6, 6

        f << "foo"
        f << "bar"
        f << "bazyx"
      end

      context "halign = :left" do
        before do
          f.halign = :left
        end

        it "aligns contents to the left" do
          expected = "foo  \nbar  \nbazyx"

          actual = f.to_s
          expect(actual).to eq expected
        end
      end

      context "halign = :right" do
        before do
          f.halign = :right
        end

        it "aligns contents to the right" do
          expected = "  foo\n  bar\nbazyx"

          actual = f.to_s
          expect(actual).to eq expected
        end
      end

      context "halign = :center" do
        before do
          f.halign = :center
        end

        it "aligns contents to the center" do
          expected = " foo \n bar \nbazyx"

          actual = f.to_s
          expect(actual).to eq expected
        end
      end
    end

    context "size = Tuple halign = :center" do
      before do
        f.halign = :center
        f.valign = :center
        f.size = Tuple(5,7)
        f.available_size = Tuple(11,11)

        f << "lol"
      end

      it "content appears centered" do
        expected = [
          "       ",
          "       ",
          "  lol  ",
          "       ",
          "       "
        ].join ?\n

        actual = f.to_s
        expect(actual).to eq expected
      end

      it "maintains centering when there are newlines in contents" do
        # I was getting this weird output:
        # ......
        # ...a..
        # ...b..
        # ..c...
        # d.....
        # This was due to the starting calculations being based on
        #   the length of unsplit lines.

        expected = [
          "   a   ",
          "   b   ",
          "   c   ",
          "   d   ",
          "       "
        ].join ?\n

        f.reset!
        f << "a"
        f << "b"
        f << "c\nd"

        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    describe "bottom alignment" do
      before do
        f.halign = :center
        f.valign = :bottom
        f.size = Tuple(5,7)
        f.available_size = Tuple(11,11)

        f << "lol"
      end

      it "content appears centered in the bottom" do
        expected = [
          "       ",
          "       ",
          "       ",
          "       ",
          "  lol  "
        ].join ?\n

        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    describe "0 height Tuple" do
      before do
        f.halign = :center
        f.valign = :bottom
        f.size = Tuple(0,7)
        f.available_size = Tuple(3,11)

        f << "lol"
      end
      it "stretches to the vertical bounds of the container" do
        expected = [
          "       ",
          "       ",
          "  lol  "
        ].join ?\n

        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    describe "0 width tuple" do
      before do
        f.halign = :center
        f.valign = :bottom
        f.size = Tuple(1,0)
        f.available_size = Tuple(3,11)

        f << "lol"
      end

      it "stretches to the horizontal bounds of the container" do
        expected = [
          "    lol    "
        ].join ?\n

        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    describe "fractional width size" do
      before do
        f.halign = :center
        f.valign = :bottom
        f.size = Tuple(0,0.5)
        f.available_size = Tuple(3,11)

        f << "lol"
      end

      it "stretches to half the horizontal bounds of the container" do
        expected = [
          "     ",
          "     ",
          " lol "
        ].join ?\n

        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    describe "fractional height size" do
      before do
        f.halign = :center
        f.valign = :bottom
        f.size = Tuple(0.5,0)
        f.available_size = Tuple(4,11)

        f << "lol"
      end

      it "stretches to half the vertical bounds of the container" do
        expected = [
          "           ",
          "    lol    "
        ].join ?\n

        actual = f.to_s
        expect(actual).to eq expected
      end
    end
  end

  describe "arrangement" do

    context "with strings"
    before do
      f << "a"
      f << "b"
      f << "c"
    end

    context "arrangement = stacked" do
      before do
        f.arrangement = :stacked
      end

      it "arranges contents on top of each other" do
        expected = "a\nb\nc"
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "arrangement = columnar" do
      before do
        f.arrangement = :columnar
      end

      it "arranges contents next to each other" do
        expected = "abc"
        actual = f.to_s
        expect(actual).to eq expected
      end
    end
  end

  context "with nested frames" do
    let(:f1) do
      f1 = described_class.new name: "f1"
      f1 << "a"
      f1
    end
    let(:f2) do
      f2 = described_class.new name: "f2"
      f2 << "b"
      f2
    end
    let(:f3) do
      f3 = described_class.new name: "f3"
      f3 << "c"
      f3.size = Tuple 3, 3
      f3.valign = :center
      f3.halign = :center
      f3
    end

    before do
      f.reset!
      f << f1
      f << f2
      f << f3
    end

    context "arrangement = stacked" do
      before do
        f.arrangement = :stacked
      end

      it "arranges contents on top of each other" do
        expected = "a\nb\n   \n c \n   "
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "arrangement = columnar" do
      before do
        f.arrangement = :columnar
      end

      it "arranges contents next to each other" do
        expected = "ab   \n c \n   "
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "arrangement = arbitrary" do
      before do
        f.arrangement = :arbitrary
        f1.depth = 3 # no longer respected??
        f1.fill = ":"
        f1.size = Tuple 1,2
        f2.fill = "*"
        f2.size = Tuple 2,1
        f3.fill = "#"
      end

      it "contents are not relative to others" do
        # f1e = "a:"
        # f2e = "b\n*" # completely covered
        # f3e = "###\n#c#\n###"

        expected = "a:#\n#c#\n###"

        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "vorigin = :bottom" do
      let(:f1) do
        f1 = described_class.new
        f1 << "a"
        f1.size = Tuple 3, 3
        f1.fill = "."
        f1
      end

      before do
        f.size = Tuple 5, 5
        f.reset!
        f << f1
      end

      it "puts the nested frame in the correct location" do
        expected = "     \n     \n ... \n .a. \n ... "
        actual = f.to_s
        expect(actual).to eq expected
      end
    end
  end

  describe "layering" do
    let(:size_override){ Tuple 7, 7 }
    let(:f1) do
      f1 = described_class.new
      f1 << "a"
      f1.size = Tuple 3, 3
      f1.fill = ":"
      f1.valign = :center
      f1.halign = :center
      f1
    end
    let(:f2) do
      f2 = described_class.new
      f2 << "b"
      f2.size = Tuple 3, 3
      f2.offset = Tuple 2, 2
      f2.fill = "*"
      f2.valign = :center
      f2.halign = :center
      f2.depth = 1
      f2
    end
    let(:f3) do
      f3 = described_class.new
      f3 << "c"
      f3.size = Tuple 3, 3
      f3.offset = Tuple 4, 4
      f3.fill = "#"
      f3.valign = :center
      f3.halign = :center
      f3.depth = 2
      f3
    end

    before do
      f.reset!
      f << f1
      f << f2
      f << f3

      f.available_size = size_override
      f.size = :fill
      f.arrangement = :arbitrary
      f.fill = "."
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

      actual = f.to_s
      expect(actual).to eq expected
    end

    xit "treats plain strings as layer 0" do
      actual = f.to_s
      expect(actual).to eq expected
    end
  end
end
