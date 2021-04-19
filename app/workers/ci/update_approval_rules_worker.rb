# frozen_string_literal: true

# Worker for syncing report_type approval_rules approvals_required
#
module Ci
  class UpdateApprovalRulesWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include SecurityScansQueue

    urgency :high
    worker_resource_boundary :cpu

    def perform(pipeline_id)
      pipeline = Ci::Pipeline.find_by_id(pipeline_id)
      return unless pipeline

      ::Ci::UpdateApprovalRulesService.new(pipeline).execute
    end
  end
end
