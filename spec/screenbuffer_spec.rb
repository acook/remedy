require_relative 'spec_helper'
require 'remedy/screenbuffer'

describe Remedy::Screenbuffer do
  subject(:sb){ described_class.new size, fill: "." }
  let(:size){ Tuple 2, 2 }

  describe "#to_s" do
    it "dumps the screenbuffer as a single string" do
      expected = "..\n.."
      actual = sb.to_s
      expect(actual).to eq expected
    end
  end

  describe "#[]=" do
    it "sets the value at a particular location for a single character" do
      value = "x"
      expected = "..\n.#{value}"
      sb[1,1] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "sets the value at a particular location for sequential characters" do
      value = "xy"
      expected = "..\n#{value}"
      sb[1,0] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "sets the value at a particular location for multiple lines" do
      value = %w{a b}
      expected = "a.\nb."
      sb[0,0] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "handles embedded newlines gracefully" do
      value = "a\nb"
      expected = ".a\n.b"
      sb[0,1] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end
  end
end
