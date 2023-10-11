require_relative "spec_helper"
require "remedy/frame"
require "remedy/partial"

describe Remedy::Frame do
  let(:sizeclass) { ::Remedy::Tuple }
  let(:console_size) { sizeclass.new 20, 40 }
  subject(:f) do
    f0 = described_class.new name: "subject"
    f0.available_size = console_size
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

  describe "#content_size" do
    it "returns a Tuple of the contents dimensions" do
      expected = Tuple 2, 4
      f << "1234"
      f << "567"

      actual = f.content_size
      expect(actual).to eq expected
    end
  end

  describe "#compute_actual_size" do
    it "returns a Tuple of the rendered size" do
      f << "1234"
      f << "567"
      arranged_size = Tuple(5, 5)

      f.size = :none
      expected = Tuple 2, 4
      actual = f.compute_actual_size arranged_size
      expect(actual).to eq expected

      f.size = :fill
      actual = f.compute_actual_size arranged_size
      expect(actual).to eq console_size

      f.size = :auto
      actual = f.compute_actual_size arranged_size
      expect(actual).to eq arranged_size

      f.size = sizeclass.zero
      actual = f.compute_actual_size arranged_size
      expect(actual).to eq console_size

      f.size = sizeclass.new 2, 2
      actual = f.compute_actual_size arranged_size
      expect(actual).to eq sizeclass.new(2, 2)

      f.size = sizeclass.new 0.5, 0.74
      actual = f.compute_actual_size arranged_size
      expect(actual).to eq sizeclass.new(10, 29)
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
    before do
      f.reset!
      f << f1
      f << f2
      f << f3

      f1.size = :none
      f2.size = :none
    end

    context "arrangement = stacked" do
      before do
        f.arrangement = :stacked
      end

      it "arranges contents on top of each other" do
        expected = "a\nb\n###\n#c#\n###"
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "arrangement = columnar" do
      before do
        f.arrangement = :columnar
      end

      it "arranges contents next to each other" do
        expected = "ab###\n  #c#\n  ###"
        actual = f.to_s
        expect(actual).to eq expected
      end
    end

    context "arrangement = arbitrary" do
      before do
        f.arrangement = :arbitrary
        f.available_size = sizeclass.zero
        f1.depth = 3
        f1.size = Tuple 1,2
        f2.size = Tuple 2,1
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
      before do
        f.size = Tuple 5, 5
        f.available_size = Tuple 5, 5
        f.arrangement = :arbitrary
        f.reset!

        f1.size = Tuple 3, 3
        f1.fill = "."

        f1.horigin = :center
        f1.vorigin = :bottom
        f << f1
      end

      it "puts the nested frame at the bottom" do
        expected = "     \n     \n ... \n .a. \n ... "
        actual = f.to_s
        expect(actual).to eq expected
      end

      context "available_size.zero? = true" do
        before do
          f.available_size = sizeclass.zero
        end

        it "still puts the nested frame at the bottom" do
          expected = "     \n     \n ... \n .a. \n ... "
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
            expected = "b  \n...\n.a.\n..."
            actual = f.to_s
            expect(actual).to eq expected
          end
        end
      end
    end
  end

  describe "layering" do
    let(:console_size){ Tuple 7, 7 }

    before do
      f.reset!
      f << f1
      f << f2
      f << f3

      f2.depth = 1
      f2.offset = Tuple 2, 2
      f3.depth = 2
      f3.offset = Tuple 4, 4

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
