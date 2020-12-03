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

    let(:total_counter) { subject.send(:total_counter) }
    let(:stale_counter) { subject.send(:stale_counter) }

    subject { described_class.new(newrev, target_branch, project) }

    context 'with load balancing disabled', :request_store, :redis do
      before do
        expect(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(false)
        expect(::Gitlab::Database::LoadBalancing::Sticking).not_to receive(:unstick_or_continue_sticking)
      end

      it 'does not attempt to stick to primary' do
        expect(subject.match?).to be true
      end

      it 'increments no counters' do
        expect { subject.match? }
          .to change { total_counter.get }.by(0)
          .and change { stale_counter.get }.by(0)
      end
    end

    context 'with load balancing enabled', :request_store, :redis do
      let(:session) { ::Gitlab::Database::LoadBalancing::Session.current }

      context 'on secondary that has caught up to primary' do
        before do
          allow(::Gitlab::Database::LoadBalancing::Sticking).to receive(:all_caught_up?).and_return(true)
          expect(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
          expect(::Gitlab::Database::LoadBalancing::Sticking).to receive(:unstick_or_continue_sticking).and_call_original
        end

        it 'continues to use the secondary' do
          expect(session.use_primary?).to be false
          expect(subject.match?).to be true
        end

        it 'only increments total counter' do
          expect { subject.match? }
            .to change { total_counter.get }.by(1)
            .and change { stale_counter.get }.by(0)
        end
      end

      context 'on secondary behind primary' do
        before do
          allow(::Gitlab::Database::LoadBalancing::Sticking).to receive(:all_caught_up?).and_return(false)
        end

        context 'with feature flag disabled' do
          before do
            stub_feature_flags(matching_merge_request_db_sync: false)
            expect(::Gitlab::Database::LoadBalancing).not_to receive(:enable?)
            expect(::Gitlab::Database::LoadBalancing::Sticking).not_to receive(:unstick_or_continue_sticking)
          end

          it 'does not check load balancing state' do
            expect(subject.match?).to be true
          end

          it 'increments no counters' do
            expect { subject.match? }
              .to change { total_counter.get }.by(0)
              .and change { stale_counter.get }.by(0)
          end
        end

        context 'load balancing enabled' do
          before do
            expect(::Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
            expect(::Gitlab::Database::LoadBalancing::Sticking).to receive(:unstick_or_continue_sticking).and_call_original
          end

          it 'sticks to the primary' do
            expect(subject.match?).to be true
            expect(session.use_primary?).to be true
          end

          it 'increments both total and stale counters' do
            expect { subject.match? }
              .to change { total_counter.get }.by(1)
              .and change { stale_counter.get }.by(1)
          end
        end
      end
    end
  end
end
