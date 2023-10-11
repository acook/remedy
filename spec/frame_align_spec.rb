require_relative "spec_helper"
require "remedy/frame"

describe Remedy::Frame do
  let(:sizeclass) { ::Remedy::Tuple }
  let(:console_size) { sizeclass.new 6, 6 }
  subject(:f) do
    f0 = described_class.new name: "subject"
    f0.available_size = console_size
    f0.arrangement = :stacked
    f0.size = :fill
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

  before do
    f << "foo"
    f << "bar\nbaz"
  end

  it "does all the things" do
    topleft      = "foo   \nbar   \nbaz   \n      \n      \n      "
    topcenter    = " foo  \n bar  \n baz  \n      \n      \n      "
    topright     = "   foo\n   bar\n   baz\n      \n      \n      "

    centerleft   = "      \nfoo   \nbar   \nbaz   \n      \n      "
    centercenter = "      \n foo  \n bar  \n baz  \n      \n      "
    centerright  = "      \n   foo\n   bar\n   baz\n      \n      "

    bottomleft   = "      \n      \n      \nfoo   \nbar   \nbaz   "
    bottomcenter = "      \n      \n      \n foo  \n bar  \n baz  "
    bottomright  = "      \n      \n      \n   foo\n   bar\n   baz"

    actual = f.to_s
    expect(actual).to eq topleft

    f.halign = :center
    actual = f.to_s
    expect(actual).to eq topcenter

    f.halign = :right
    actual = f.to_s
    expect(actual).to eq topright

    f.valign = :center

    f.halign = :left
    actual = f.to_s
    expect(actual).to eq centerleft

    f.halign = :center
    actual = f.to_s
    expect(actual).to eq centercenter

    f.halign = :right
    actual = f.to_s
    expect(actual).to eq centerright

    f.valign = :bottom

    f.halign = :left
    actual = f.to_s
    expect(actual).to eq bottomleft

    f.halign = :center
    actual = f.to_s
    expect(actual).to eq bottomcenter

    f.halign = :right
    actual = f.to_s
    expect(actual).to eq bottomright
  end

end
