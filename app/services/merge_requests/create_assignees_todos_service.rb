# frozen_string_literal: true

module MergeRequests
  class CreateAssigneesTodosService
    include BaseServiceUtility

    def initialize(merge_request, user, old_assignees)
      @merge_request = merge_request
      @user = user
      @old_assignees = old_assignees
    end

    def async_execute
      if Feature.enabled?(:create_merge_request_assignees_todos_async, default_enabled: :yaml)
        MergeRequests::CreateAssigneesTodosWorker
          .perform_async(merge_request.id, user.id, old_assignees.pluck(:id))
      else
        execute
      end
    end

    def execute
      todo_service.reassigned_assignable(merge_request, user, old_assignees)
    end

    private

    attr_reader :merge_request, :user, :old_assignees
  end
end
