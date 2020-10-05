# frozen_string_literal: true

module EE
  module MergeRequests
    module AfterCreateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(merge_request)
        super

        schedule_sync_for(merge_request.head_pipeline_id)
      end

      private

      def schedule_sync_for(pipeline_id)
        ::SyncSecurityReportsToReportApprovalRulesWorker.perform_async(pipeline_id) if pipeline_id
      end
    end
  end
end
