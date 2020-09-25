# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Reports::LicenseScanning::Dependency do
  describe 'value equality' do
    let(:set) { Set.new }

    it 'cannot add the same dependency to a set twice' do
      set.add(described_class.new(name: 'bundler'))
      set.add(described_class.new(name: 'bundler'))

      expect(set.count).to eq(1)
    end

    it { expect(described_class.new(name: 'bundler')).to eql(described_class.new(name: 'bundler')) }
  end
end
