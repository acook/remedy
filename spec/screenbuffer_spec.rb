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

  describe "#[]" do
    it "returns the character at a particular location" do
      expected = "x"
      coords = ::Remedy::Tuple.tuplify 1, 1
      sb.buf = [
        "ab",
        "yx"
      ]

      actual = sb[coords]
      expect(actual).to eq expected
    end
  end

  describe "#[]=" do
    it "accepts Tuples as coordinates" do
      value = "x"
      expected = "..\n.#{value}"
      coords = ::Remedy::Tuple.tuplify 1, 1
      sb[coords] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

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

    it "accepts partials" do
      value = Remedy::Partial.new ["a\nb"]
      expected = ".a\n.b"
      sb[0,1] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "accepts views" do
      value = Remedy::View.new Remedy::Partial.new ["a\nb"]
      expected = ".a\n.b"
      sb[0,1] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    context "larger size" do
      let(:size){ Tuple 4, 4 }

      it "handles embedded newlines gracefully for multiple lines" do
        value = ["a\nb", "c"]
        expected = "....\n...a\n...b\n...c"
        sb[1,3] = value
        actual = sb.to_s
        expect(actual).to eq expected
      end
    end

    it "truncates horizontal overflows" do
      value = "1234"
      expected = "1…\n.."
      sb[0,0] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "truncates vertical overflows" do
      value = %w(1 2 3)
      expected = "..\n1."
      sb[1,0] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "truncates content when passed a negative index" do
      # this enabled resizing the terminal smaller than fixed content sizes
      # and moving windows partially off screen

      value = %w(1 2 3)
      expected = "2.\n3."
      sb[-1,0] = value
      actual = sb.to_s
      expect(actual).to eq expected
    end

    context "without ellipsis" do
      subject(:sb){ described_class.new size, fill: ".", ellipsis: nil }

      it "truncates horizontal overflows" do
        value = "1234"
        expected = "12\n.."
        sb[0,0] = value
        actual = sb.to_s
        expect(actual).to eq expected
      end
    end

    it "can be resized" do
      expected = ".....\n....."
      sb.size = Tuple 2, 5
      actual = sb.to_s
      expect(actual).to eq expected
    end

    it "generates terminal safe output strings" do
      expected = "..\e[1B\e[0G.."
      actual = sb.to_ansi
      expect(actual).to eq expected
    end
  end

  describe "#reset" do
    it "resets the contents of the buffer" do
      expected = "..\n.."

      sb[0,0] = ["ab", "cd"]
      expect(sb.to_s).to eq "ab\ncd"

      sb.reset!
      actual = sb.to_s

      expect(actual).to eq expected
    end
  end

  describe "#resize" do
    xit "extends the buffer without destroying the contents"
    xit "updates the size field properly"
    xit "outputs constrained array after shrinking"
  end

  describe "option fit = true" do
    xit "automatically grows the buffer when content does not fit"
  end
end
