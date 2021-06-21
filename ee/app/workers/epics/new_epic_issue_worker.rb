# frozen_string_literal: true

module Epics
  class NewEpicIssueWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    sidekiq_options retry: 3

    feature_category :epics
    worker_resource_boundary :cpu
    weight 2

    def perform(epic_id, issue_id, user_id, params)
      epic = ::Epic.find_by_id(epic_id)
      return unless epic

      issue = ::Issue.find_by_id(issue_id)
      return unless issue

      user = ::User.find_by_id(user_id)
      return unless user

      create_notes(epic, issue, user, params)
      usage_ping_record_epic_issue_added(user)
    end

    def create_notes(epic, issue, user, params)
      if params[:issue_moved]
        SystemNoteService.epic_issue_moved(params[:original_epic], issue, epic, user)
        SystemNoteService.issue_epic_change(issue, epic, user)
      else
        SystemNoteService.epic_issue(epic, issue, user, :added)
        SystemNoteService.issue_on_epic(issue, epic, user, :added)
      end
    end

    def usage_ping_record_epic_issue_added(user)
      ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_issue_added(author: user)
    end
  end
end
