# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::HandleReviewersChangeWorker do
  include AfterNextHelpers

  let_it_be(:merge_request) { create(:merge_request) }
  let_it_be(:user) { create(:user) }
  let_it_be(:old_reviewers) { create_list(:user, 3) }

  let(:user_ids) { old_reviewers.map(&:id).to_a }
  let(:worker) { described_class.new }

  it_behaves_like 'an idempotent worker' do
    let(:job_args) { [merge_request.id, user.id, user_ids] }
  end

  describe '#perform' do
    it 'calls MergeRequests::HandleReviewersChangeService#execute to handle the changes' do
      expect_next(::MergeRequests::HandleReviewersChangeService)
        .to receive(:execute).with(merge_request, old_reviewers)

      worker.perform(merge_request.id, user.id, user_ids)
    end

    context 'when there are no changes' do
      it 'still calls MergeRequests::HandleReviewersChangeService#execute' do
        expect_next(::MergeRequests::HandleReviewersChangeService)
          .to receive(:execute).with(merge_request, [])

        worker.perform(merge_request.id, user.id, merge_request.reviewer_ids)
      end
    end

    context 'when the old assignees cannot be found' do
      it 'still calls MergeRequests::HandleReviewersChangeService#execute' do
        expect_next(::MergeRequests::HandleReviewersChangeService)
          .to receive(:execute).with(merge_request, [])

        worker.perform(merge_request.id, user.id, [non_existing_record_id])
      end
    end

    context 'with a non-existing merge request' do
      it 'does nothing' do
        expect(::MergeRequests::HandleReviewersChangeService).not_to receive(:new)

        worker.perform(non_existing_record_id, user.id, user_ids)
      end
    end

    context 'with a non-existing user' do
      it 'does nothing' do
        expect(::MergeRequests::HandleReviewersChangeService).not_to receive(:new)

        worker.perform(merge_request.id, non_existing_record_id, user_ids)
      end
    end
  end
end
