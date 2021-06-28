# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Diff::FileCollection::MergeRequestDiffBase do
  let(:merge_request) { create(:merge_request) }
  let(:diffable) { merge_request.merge_request_diff }

  describe '#overflow?' do
    subject(:overflown) { described_class.new(diffable, diff_options: nil).overflow? }

    context 'when it is not overflown' do
      it 'returns false' do
        expect(overflown).to eq(false)
      end
    end

    context 'when it is overflown' do
      before do
        diffable.update!(state: :overflow)
      end

      it 'returns true' do
        expect(overflown).to eq(true)
      end
    end
  end
end
