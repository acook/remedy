require_relative "spec_helper"
require "remedy/tuple"

describe Remedy::Tuple do
  subject(:t){ described_class.new 1, 1 }

  describe "#==" do
    context "when other Tuple is the same" do
      let(:other){ described_class.new 1, 1  }

      it "can tell when another Tuple has the same dimensional coordinates" do
        expect(t == other).to be true
      end
    end

    context "when other is an Array" do
      let(:other){ [1,1] }

      it "can tell that they are the same" do
        expect(t == other).to be true
      end
    end

    context "when other Tuple has a different y" do
      let(:other){ described_class.new 1, 2 }

      it "can tell that another Tuple is different" do
        expect(t == other).to be false
      end
    end

    context "when other Tuple has a different cardinality" do
      let(:other){ described_class.new 1, 1, 1 }

      it "can tell that another Tuple is different" do
        expect(t == other).to be false
      end
    end
  end

  describe "#dup" do
    let(:other){ t.dup }

    it "creates a new dimension array" do
      expect(other[1] == t[1]).to be true
      t[1] = 88
      expect(other[1] == t[1]).to be false
    end
  end
end
