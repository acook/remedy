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
  end
end
