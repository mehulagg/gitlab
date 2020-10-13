# frozen_string_literal: true

module EE
  module MergeRequests
    module RemoveApprovalService
      extend ::Gitlab::Utils::Override

      private

      override :reset_approvals_cache
      def reset_approvals_cache(merge_request)
        merge_request.reset_approval_cache!
      end

      override :trigger_approval_hooks
      def trigger_approval_hooks(merge_request)
        currently_approved = merge_request.approved?

        yield

        if currently_approved
          notification_service.async.unapprove_mr(merge_request, current_user)
          execute_hooks(merge_request, 'unapproved')
        else
          execute_hooks(merge_request, 'unapproval')
        end
      end
    end
  end
end
