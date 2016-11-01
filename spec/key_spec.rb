require_relative 'spec_helper'
require 'remedy/key'

describe Remedy::Key do
  subject(:key){ described_class.new keypress }

  let(:keypress){ "\e[A" }

  describe '#raw' do
    it 'gives the same sequence it was initialized with' do
      expect(key.raw).to equal(keypress)
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

  describe '#nonprintable?' do
    it 'indicates that a keypress is a nonprintable character or sequence' do
      expect(key.nonprintable?).to be(true)
    end
  end

  describe '#sequence?' do
    it 'determines if a keypress is an escape sequence' do
      expect(key.sequence?).to be(true)
    end
  end

  describe 'control characters' do
    let(:keypress){ 3.chr }

    it 'recognizes control c' do
      expect(key.control_c?).to be(true)
    end
  end
end
