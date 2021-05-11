# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Matching::RunnerMatcher::Factory do
  describe '#create' do
    subject(:subject) { described_class.new(record).create } # rubocop:disable Rails/SaveBang

    context 'when the record is nil' do
      let(:record) {}

      it { is_expected.to be_empty }
    end

    context 'with runners relationship' do
      before do
        create(:ci_runner)
      end

      let(:record) { Ci::Runner.all }

      it { is_expected.to all be_a(Gitlab::Ci::Matching::RunnerMatcher) }
    end

    context 'with builds' do
      let(:record) { build_stubbed(:ci_runner) }

      it { is_expected.to all be_a(Gitlab::Ci::Matching::RunnerMatcher) }
    end
  end
end
