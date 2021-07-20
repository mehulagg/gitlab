# frozen_string_literal: true

module MergeRequests
  class ResetApprovalsService < ::MergeRequests::BaseService
    def execute(ref, newrev)
      reset_approvals_for_merge_requests(ref, newrev)
    end

    private

    # Note: Closed merge requests also need approvals reset.
    def reset_approvals_for_merge_requests(ref, newrev)
      branch_name = ::Gitlab::Git.ref_name(ref)
      merge_requests = merge_requests_for(branch_name, mr_states: [:opened, :closed])

      merge_requests.each do |merge_request|
        reset_approvals(merge_request, newrev)
      end
    end

    def reset_approvals?(merge_request, newrev)
      super && merge_request.rebase_commit_sha != newrev
    end
  end
end
