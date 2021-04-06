# frozen_string_literal: true

module MergeRequests
  class CreateReviewersTodosService
    include BaseServiceUtility

    def initialize(merge_request, user, old_reviewers)
      @merge_request = merge_request
      @user = user
      @old_reviewers = old_reviewers
    end

    def async_execute
      if Feature.enabled?(:create_merge_request_reviewers_todos_async, default_enabled: :yaml)
        MergeRequests::CreateReviewersTodosWorker
          .perform_async(merge_request.id, user.id, old_reviewers.pluck(:id))
      else
        execute
      end
    end

    def execute
      todo_service.reassigned_reviewable(merge_request, user, old_reviewers)
    end

    private

    attr_reader :merge_request, :user, :old_reviewers
  end
end
