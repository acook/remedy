require_relative "spec_helper"
require "remedy/frame"
require "remedy/partial"

describe Remedy::Frame do
  subject(:f){ described_class.new }

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
      f.contents << content
      actual = f.to_s
      expect(actual).to eq expected
    end

    it "compiles the contents of multiple strings" do
      expected = "foo\nbar\nbaz"
      f.contents << "foo"
      f.contents << "bar"
      f.contents << "baz"
      actual = f.to_s
      expect(actual).to eq expected
    end

    it "compiles the contents of partials" do
      expected = "foo\nbar"
      f.contents << "foo"
      f.contents << ::Remedy::Partial.new(["bar"])
      actual = f.to_s
      expect(actual).to eq expected
    end

    context "max_size = Tuple" do
      before do
        f.max_size = Tuple 5, 5
        f.available_size = Tuple 7, 7

        f.contents << "foo"
        f.contents << "bar"
        f.contents << "baz"
      end

      context "halign = :left" do
        before do
          f.halign = :left
        end

        it "fills and aligns contents to the left" do
          expected = "foo  \nbar  \nbaz  "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end
    end

    context "max_size = :fill" do
      before do
        f.max_size = :fill
        f.available_size = Tuple 6, 6

        f.contents << "foo"
        f.contents << "bar"
        f.contents << "baz"
      end

      context "halign = :left" do
        before do
          f.halign = :left
        end

        it "fills and aligns contents to the left" do
          expected = "foo   \nbar   \nbaz   "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end

      context "halign = :right" do
        before do
          f.halign = :right
        end

        it "fills and aligns contents to the right" do
          expected = "   foo\n   bar\n   baz"

          actual = f.to_s
          expect(actual).to eq expected
        end
      end

      context "halign = :center" do
        before do
          f.halign = :center
        end

        it "fills and aligns contents to the center" do
          expected = " foo  \n bar  \n baz  "

          actual = f.to_s
          expect(actual).to eq expected
        end
      end
    end

    context "max_size = :auto" do
      before do
        f.max_size = :auto
        f.available_size = Tuple 6, 6

        f.contents << "foo"
        f.contents << "bar"
        f.contents << "bazyx"
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
  end
end
