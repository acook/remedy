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

  describe "#abs" do
    it "returns a version of the tuple where all dimensions are positive" do
      n = described_class.new -1, -0.5
      expected = described_class.new 1, 0.5
      actual = n.abs
      expect(actual).to eq expected
    end
  end

  describe "#aod" do
    context "other has same cardinality" do
      let(:other) { described_class.new 0, 2 }

      it "returns a Tuple with the area of difference" do
        expected = described_class.new 1, 1
        actual = t.aod other
        expect(actual).to eq expected
      end
    end

    context "other has smaller cardinality" do
      let(:other) { described_class.new 3 }

      it "returns a Tuple with the area of difference" do
        expected = described_class.new 2, 1
        actual = t.aod other
        expect(actual).to eq expected
      end
    end

    context "other has larger cardinality" do
      let(:other) { described_class.new -1, 1, 3 }

      it "returns a Tuple with the area of difference" do
        expected = described_class.new 2, 0, 3
        actual = t.aod other
        expect(actual).to eq expected
      end
    end
  end

  describe "#aold" do
    context "other has same cardinality" do
      let(:other) { described_class.new 0, 2 }

      it "returns a Tuple with the area of lesser difference" do
        expected = described_class.new 1, 0
        actual = t.aold other
        expect(actual).to eq expected
      end
    end

    context "other has smaller cardinality" do
      let(:other) { described_class.new 3 }

      it "returns a Tuple with the area of lesser difference" do
        expected = described_class.new 0, 1
        actual = t.aold other
        expect(actual).to eq expected
      end
    end

    context "other has larger cardinality" do
      let(:other) { described_class.new -1, 1, 3 }

      it "returns a Tuple with the area of lesser difference" do
        expected = described_class.new 2, 0, 0
        actual = t.aold other
        expect(actual).to eq expected
      end
    end
  end

  describe "#aogd" do
    context "other has same cardinality" do
      let(:other) { described_class.new 0, 2 }

      it "returns a Tuple with the area of greater difference" do
        expected = described_class.new 0, 1
        actual = t.aogd other
        expect(actual).to eq expected
      end
    end

    context "other has smaller cardinality" do
      let(:other) { described_class.new 3 }

      it "returns a Tuple with the area of greater difference" do
        expected = described_class.new 2, 0
        actual = t.aogd other
        expect(actual).to eq expected
      end
    end

    context "other has larger cardinality" do
      let(:other) { described_class.new -1, 1, 3 }

      it "returns a Tuple with the area of greater difference" do
        expected = described_class.new 0, 0, 3
        actual = t.aogd other
        expect(actual).to eq expected
      end
    end
  end

  describe "#zero?" do
    it "returns true when all dimensions are zero" do
      z = described_class.new 0, 0
      expected = true
      actual = z.zero?
      expect(actual).to eq expected
    end
  end

  describe "#nonzero?" do
    it "returns true when any dimension is not zero" do
      z = described_class.new 1, 0
      expected = true
      actual = z.nonzero?
      expect(actual).to eq expected
    end
  end

  describe "#<=>" do
    context "other Tuple is larger" do
      let(:other){ described_class.new 2, 2 }

      it "returns -1" do
        expected = -1
        actual = t <=> other
        expect(actual).to eq expected
      end

      it "returns -1 due to magnitude" do
        other = described_class.new 0, 3
        expected = -1
        actual = t <=> other
        expect(actual).to eq expected
      end
    end

    context "other Tuple is smaller" do
      let(:other){ described_class.new 0, 0 }

      it "returns 1 when the other tuple is lesser" do
        expected = 1
        actual = t <=> other
        expect(actual).to eq expected
      end
    end

    context "other Tuple is the same size" do
      let(:other){ t.dup }

      it "returns 0" do
        expected = 0
        actual = t <=> other
        expect(actual).to eq expected
      end
    end
  end

  describe "#fits_into?" do
    context "other has same cardinality" do
      context "and is bigger in one dimension but smaller in another" do
        let(:other) { described_class.new 0, 2 }

        it "does not fit" do
          expected = false
          actual = t.fits_into? other
          expect(actual).to eq expected
        end
      end

      context "and is bigger in one dimension but equal in another" do
        let(:other) { described_class.new 1, 2 }

        it "returns a Tuple with the area of greater difference" do
          expected = true
          actual = t.fits_into? other
          expect(actual).to eq expected
        end
      end
    end

    context "other has smaller cardinality" do
      let(:other) { described_class.new 3 }

      it "does not fit" do
        expected = false
        actual = t.fits_into? other
        expect(actual).to eq expected
      end
    end

    context "other has larger cardinality" do
      context "and has a negative dimension" do
        let(:other) { described_class.new -1, 1, 3 }

        it "does not fit" do
          expected = false
          actual = t.fits_into? other
          expect(actual).to eq expected
        end
      end

      context "has more dimensions which are the same size" do
        let(:other) { described_class.new 1, 1, 1 }

        it "does fit" do
          expected = true
          actual = t.fits_into? other
          expect(actual).to eq expected
        end
      end
    end
  end
end
