require_relative "spec_helper"
require "remedy/frame"

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
end
