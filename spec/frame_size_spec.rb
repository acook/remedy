require_relative "spec_helper"
require "remedy/frame"

describe Remedy::Frame do
  let(:sizeclass) { ::Remedy::Tuple }
  let(:console_size) { sizeclass.new 6, 6 }
  subject(:f) do
    f0 = described_class.new name: "subject"
    f0.available_size = console_size
    f0
  end

  before do
    f << "foo"
    f << "bar\nbaz"
  end

  context "stacked arrangement" do
    before do
      f.arrangement = :stacked
    end

    it "occupies the size specified" do
      expected = "foo  \nbar  \nbaz  \n     \n     "
      f.size = Tuple 5, 5
      actual = f.to_s
      expect(actual).to eq expected
    end

    describe "#resize" do
      let(:new_size) { sizeclass.new 5, 5 }

      before do
        f.size = :fill
      end

      it "resizes the buffer" do
        f.compile_contents
        expect(f.compute_actual_size).to eq console_size
        f.available_size = new_size
        expect(f.compute_actual_size).to eq new_size
        f.compile_contents # buffer size is not updated until recompile
        expect(f.buffer.size).to eq new_size
      end
    end

    it "does all the things" do
      none = "foo\nbar\nbaz"
      fill = "foo:::\nbar:::\nbaz:::\n::::::\n::::::\n::::::"
      auto = "foo   \nbar   \nbaz   \n      \n      \n      " # ??
      t5x5 = "foo::\nbar::\nbaz::\n:::::\n:::::"
      tzxs = "f…\nb…\nb…\n::\n::\n::"
      tbxf = "foo\nbar\nbaz\n:::\n:::\n:::\n:::"

      f.fill = ":"

      f.size = :none
      actual = f.to_s
      expect(actual).to eq none

      f.size = :fill
      actual = f.to_s
      expect(actual).to eq fill

      f.size = :auto
      actual = f.to_s
      #expect(actual).to eq auto

      f.size = Tuple 5, 5
      actual = f.to_s
      expect(actual).to eq t5x5

      f.size = Tuple 0, 2
      actual = f.to_s
      expect(actual).to eq tzxs

      f.size = Tuple 7, 0.5
      actual = f.to_s
      expect(actual).to eq tbxf
    end
  end

end
