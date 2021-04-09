# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::HandleReviewersChangeService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }
  let_it_be(:reviewer) { create(:user) }
  let_it_be(:merge_request) { create(:merge_request, author: user, source_project: project, reviewers: [reviewer]) }
  let_it_be(:old_reviewers) { create_list(:user, 3) }

  let(:service) { described_class.new(project, user) }

  before_all do
    project.add_maintainer(user)
    project.add_developer(reviewer)

    old_reviewers.each do |reviewer|
      project.add_developer(reviewer)
    end
  end

  describe '#async_execute' do
    def async_execute
      service.async_execute(merge_request, old_reviewers)
    end

    it 'performs MergeRequests::HandleReviewersChangeWorker asynchronously' do
      expect(MergeRequests::HandleReviewersChangeWorker)
        .to receive(:perform_async)
        .with(
          merge_request.id,
          user.id,
          old_reviewers.map(&:id)
        )

      async_execute
    end

    context 'when async_handle_merge_request_reviewers_change feature is disabled' do
      before do
        stub_feature_flags(async_handle_merge_request_reviewers_change: false)
      end

      it 'calls #execute' do
        expect(service).to receive(:execute).with(merge_request, old_reviewers)

        async_execute
      end
    end
  end

  describe '#execute' do
    def execute
      service.execute(merge_request, old_reviewers)
    end

    it 'creates reviewer note' do
      execute

      note = merge_request.notes.last

      expect(note).not_to be_nil
      expect(note.note).to include "requested review from #{reviewer.to_reference}"
    end

    it 'sends email notifications to old and new reviewers', :mailer, :sidekiq_inline do
      perform_enqueued_jobs do
        execute
      end

      should_email(reviewer)
      old_reviewers.each do |old_reviewer|
        should_email(old_reviewer)
      end
    end

    it 'creates pending todo for reviewer' do
      execute

      todo = reviewer.todos.last

      expect(todo).to be_pending
    end

    it 'invalidates cache counts of affected reviewers' do
      expect(service).to receive(:invalidate_cache_counts).with(merge_request, users: match_array([reviewer] + old_reviewers))

      execute
    end

    it 'tracks reviewers changed event' do
      expect(Gitlab::UsageDataCounters::MergeRequestActivityUniqueCounter)
        .to receive(:track_reviewers_changed_action).once.with(user: user)

      execute
    end

    it 'tracks reviewers changed event' do
      expect(Gitlab::UsageDataCounters::MergeRequestActivityUniqueCounter)
        .to receive(:track_users_review_requested)
        .with(users: [reviewer])

      execute
    end
  end
end
