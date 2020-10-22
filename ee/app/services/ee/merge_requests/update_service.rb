# frozen_string_literal: true

module EE
  module MergeRequests
    module UpdateService
      extend ::Gitlab::Utils::Override

      include CleanupApprovers

      override :execute
      def execute(merge_request)
        unless update_task_event?
          should_remove_old_approvers = params.delete(:remove_old_approvers)
          old_approvers = merge_request.overall_approvers(exclude_code_owners: true)
        end

        reset_approval_rules(merge_request) if params.delete(:reset_approval_rules_to_defaults)

        merge_request = super(merge_request)

        if should_remove_old_approvers && merge_request.valid?
          cleanup_approvers(merge_request, reload: true)
        end

        merge_request.reset_approval_cache!

        return merge_request if update_task_event?

        new_approvers = all_approvers(merge_request) - old_approvers

        if new_approvers.any?
          todo_service.add_merge_request_approvers(merge_request, new_approvers)
          notification_service.add_merge_request_approvers(merge_request, new_approvers, current_user)
        end

        ::MergeRequests::UpdateBlocksService
          .new(merge_request, current_user, blocking_merge_requests_params)
          .execute

        merge_request
      end

      private

      override :create_branch_change_note
      def create_branch_change_note(merge_request, branch_type, old_branch, new_branch)
        super

        reset_approvals(merge_request)
      end

      override :handle_assignees_change
      def handle_assignees_change(merge_request, _old_assignees)
        super

        return unless merge_request.project.feature_available?(:code_review_analytics)

        ::Analytics::RefreshReassignData.new(merge_request).execute_async
      end

      def reset_approval_rules(merge_request)
        return unless merge_request.project.can_override_approvers?

        merge_request.approval_rules.regular_or_any_approver.delete_all
      end
    end
  end
end
