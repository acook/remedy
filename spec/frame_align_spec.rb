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

    context "fill size" do
      before do
        f.size = :fill
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

    context "fixed size" do
      before do
        f.size = Tuple 5, 5
      end

      it "does all the things" do
        topleft      = "foo  \nbar  \nbaz  \n     \n     "
        topcenter    = " foo \n bar \n baz \n     \n     "
        topright     = "  foo\n  bar\n  baz\n     \n     "

        centerleft   = "     \nfoo  \nbar  \nbaz  \n     "
        centercenter = "     \n foo \n bar \n baz \n     "
        centerright  = "     \n  foo\n  bar\n  baz\n     "

        bottomleft   = "     \n     \nfoo  \nbar  \nbaz  "
        bottomcenter = "     \n     \n foo \n bar \n baz "
        bottomright  = "     \n     \n  foo\n  bar\n  baz"

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

  end

  context "columnar arrangement" do
    let(:console_size) { sizeclass.new 4, 8 }
    before do
      f.arrangement = :columnar
    end

    context "fill size" do
      before do
        f.size = :fill
      end

      it "does all the things" do
        topleft      = "foobar  \n   baz  \n        \n        "
        topcenter    = " foobar \n    baz \n        \n        "
        topright     = "  foobar\n     baz\n        \n        "

        centerleft   = "        \nfoobar  \n   baz  \n        "
        centercenter = "        \n foobar \n    baz \n        "
        centerright  = "        \n  foobar\n     baz\n        "

        bottomleft   = "        \n        \nfoobar  \n   baz  "
        bottomcenter = "        \n        \n foobar \n    baz "
        bottomright  = "        \n        \n  foobar\n     baz"

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

    context "fixed size" do
      before do
        f.size = Tuple 5, 7
      end

      it "does all the things" do
        topleft      = "foobar \n   baz \n       \n       \n       "
        topcenter    = "foobar \n   baz \n       \n       \n       "
        topright     = " foobar\n    baz\n       \n       \n       "

        centerleft   = "       \nfoobar \n   baz \n       \n       "
        centercenter = "       \nfoobar \n   baz \n       \n       "
        centerright  = "       \n foobar\n    baz\n       \n       "

        bottomleft   = "       \n       \n       \nfoobar \n   baz "
        bottomcenter = "       \n       \n       \nfoobar \n   baz "
        bottomright  = "       \n       \n       \n foobar\n    baz"

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

  end

end
