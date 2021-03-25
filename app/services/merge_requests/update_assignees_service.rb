# frozen_string_literal: true

module MergeRequests
  class UpdateAssigneesService < UpdateService
    def execute(merge_request)
      return unless current_user&.can?(:update_merge_request, merge_request)

      old_assignees = merge_request.assignees.to_a
      merge_request.update!(assignee_ids: assignee_ids)

      MergeRequests::AssigneesChangeWorker
        .perform_async(merge_request.id, current_user.id, old_assignees.map(&:id))
    end

    def assignee_ids
      params.fetch(:assignee_ids).take(1) # rubocop: disable CodeReuse/ActiveRecord (false positive)
    end

    def handle_assignee_changes(merge_request, old_assignees)
      # exposes private method from super-class
      handle_assignees_change(merge_request, old_assignees)
    end
  end
end

MergeRequests::UpdateAssigneesService.prepend_if_ee('EE::MergeRequests::UpdateAssigneesService')
