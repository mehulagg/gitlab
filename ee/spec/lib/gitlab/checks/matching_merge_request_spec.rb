# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Checks::MatchingMergeRequest do
  describe '#match?' do
    let_it_be(:newrev) { '012345678' }
    let_it_be(:target_branch) { 'feature' }
    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:locked_merge_request) do
      create(:merge_request,
        :locked,
        source_project: project,
        target_project: project,
        target_branch: target_branch,
        in_progress_merge_commit_sha: newrev)
    end

    subject { described_class.new(newrev, target_branch, project) }

    context 'with load balancing disabled', :request_store, :redis do
      before do
        expect(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(false)
      end

      it 'does not attempt to stick to primary' do
        expect(::Gitlab::Database::LoadBalancing::Sticking).not_to receive(:unstick_or_continue_sticking)

        expect(subject.match?).to be true
      end
    end

    context 'with load balancing enabled', :request_store, :redis do
      before do
        allow(::Gitlab::Database::LoadBalancing::Sticking).to receive(:all_caught_up?).and_return(false)
      end

      context 'with feature flag disabled' do
        before do
          stub_feature_flags(matching_merge_request_db_sync: false)
        end

        it 'does not check load balancing state' do
          expect(::Gitlab::Database::LoadBalancing).not_to receive(:enable?)
          expect(::Gitlab::Database::LoadBalancing::Sticking).not_to receive(:unstick_or_continue_sticking)

          expect(subject.match?).to be true
        end
      end

      it 'sticks to the primary' do
        session = ::Gitlab::Database::LoadBalancing::Session.current
        expect(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
        expect(::Gitlab::Database::LoadBalancing::Sticking).to receive(:unstick_or_continue_sticking).and_call_original

        expect(subject.match?).to be true
        expect(session.use_primary?).to be true
      end
    end
  end
end
