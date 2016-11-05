require_relative 'spec_helper'
require 'remedy/partial'

describe Remedy::Partial do
  subject { described_class.new.tap{|p| p << "foo"; p << "bar"; p << "remedy" } }

  describe '#width' do
    it 'gives length of longest line' do
      expect(subject.width).to eq 6
    end
  end
end
