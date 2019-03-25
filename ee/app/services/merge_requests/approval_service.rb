# frozen_string_literal: true

module MergeRequests
  class ApprovalService < MergeRequests::BaseService
    def execute(merge_request)
      approval = merge_request.approvals.new(user: current_user)

      if save_approval(approval)
        merge_request.reset_approval_cache!

        create_approval_note(merge_request)
        mark_pending_todos_as_done(merge_request)

        if merge_request.approvals_left.zero?
          notification_service.async.approve_mr(merge_request, current_user)
          execute_hooks(merge_request, 'approved')
        end
      end
    end

    private

    def save_approval(approval)
      Approval.safe_ensure_unique do
        approval.save
      end
    end

    def create_approval_note(merge_request)
      SystemNoteService.approve_mr(merge_request, current_user)
    end

    def mark_pending_todos_as_done(merge_request)
      todo_service.mark_pending_todos_as_done(merge_request, current_user)
    end
  end
end
