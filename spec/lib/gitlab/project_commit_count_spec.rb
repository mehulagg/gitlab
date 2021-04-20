# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ProjectCommitCount do
  describe '.commit_count_for' do
    subject { described_class.commit_count_for(project, default_count: 42) }

    context 'when a root_ref exists' do
      let(:project) { create(:project, :repository) }

      it 'returns commit count from GitlayClient' do
        allow(Gitlab::GitalyClient).to receive(:call).and_call_original
        allow(Gitlab::GitalyClient).to receive(:call).with(anything, :commit_service, :count_commits, anything, anything)
          .and_return(double(count: 4))

        expect(subject).to eq(4)
      end
    end

    context 'when a root_ref does not exist' do
      let(:project) { create(:project, :empty_repo) }

      it 'returns the default_count' do
        expect(subject).to eq(42)
      end
    end
  end
end
