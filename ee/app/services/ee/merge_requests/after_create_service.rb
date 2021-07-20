# frozen_string_literal: true

module EE
  module MergeRequests
    module AfterCreateService
      extend ::Gitlab::Utils::Override

      override :prepare_merge_request
      def prepare_merge_request(merge_request)
        super

        schedule_sync_for(merge_request.head_pipeline_id)
      end

      private

      def schedule_sync_for(pipeline_id)
        ::Ci::SyncReportsToReportApprovalRulesWorker.perform_async(pipeline_id) if pipeline_id
      end
    end
  end
end
