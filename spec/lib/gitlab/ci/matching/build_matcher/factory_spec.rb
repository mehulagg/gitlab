# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::BuildMatcher::Factory do
  describe '#create' do
    subject(:subject) { described_class.new(record).create } # rubocop:disable Rails/SaveBang

    context 'when the record is nil' do
      let(:record) {}

      it { is_expected.to be_empty }
    end

    context 'when the strategy is not available for the record' do
      let(:record) { build_stubbed(:ci_bridge) }

      it { is_expected.to be_empty }
    end

    context 'with pipelines' do
      let(:record) { create(:ci_pipeline, :with_report_results) }

      it { is_expected.to all be_a(Gitlab::Ci::Matching::BuildMatcher) }
    end

    context 'with builds' do
      let(:record) { build_stubbed(:ci_build) }

      it { is_expected.to all be_a(Gitlab::Ci::Matching::BuildMatcher) }
    end
  end
end
