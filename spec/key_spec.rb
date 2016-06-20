require 'bundler'
Bundler.require(:test)
require 'pry'

require 'remedy/key'

describe Remedy::Key do
  subject(:key){ described_class.new up }

  let(:up){ "\e[A" }

  describe '#raw' do
    it 'gives the same sequence it was initialized with' do
      expect(key.raw).to equal(up)
    end
  end

  describe '#name' do
    it 'gives the name of the key' do
      expect(key.name).to equal(:up)
    end
  end

  describe '#glyph' do
    it 'gives the individual character respresentation of the key' do
      expect(key.glyph).to eq("\u2191")
    end
  end

  describe '#special?' do
    it 'indicates if the key is a special multibyte sequence' do
      expect(key.nonprintable?).to be(true)
    end
  end
end
