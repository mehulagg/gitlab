# frozen_string_literal: true

module EE
  module MergeRequests
    module CreateService
      extend ::Gitlab::Utils::Override

      override :after_create
      def after_create(issuable)
        super

        ::MergeRequests::SyncCodeOwnerApprovalRules.new(issuable).execute

        ::MergeRequests::SyncReportApproverApprovalRulesWorker.perform_async(issuable.id)

        ::MergeRequests::UpdateBlocksService
          .new(issuable, current_user, blocking_merge_requests_params)
          .execute
      end
    end
  end
end
