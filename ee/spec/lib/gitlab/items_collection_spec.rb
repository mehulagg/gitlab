# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ItemsCollection do
  let(:collection) { described_class.new(items) }
  let(:items) { Array.new(42, :dependency) }

  it 'responds to each' do
    expect(collection).to respond_to(:each)
  end

  describe '#page' do
    subject { collection.page(3) }

    it 'returns paginated collection' do
      expect(subject.length).to eq(2)
    end
  end

  describe '#to_ary' do
    subject { collection.to_ary }

    it 'returns Array' do
      is_expected.to be_an(Array)
    end
  end
end
