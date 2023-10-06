require_relative "spec_helper"
require "remedy/align"

describe Remedy::Align do
  subject(:a){ described_class }

  describe ".h_center_pad" do
    it "centers a single string horizontally with padding" do
      expected = " foo "
      actual = a.h_center_pad "foo", Tuple(10,5)

      expect(actual).to eq expected
    end
  end

end
