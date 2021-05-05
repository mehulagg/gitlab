# frozen_string_literal: true

# Worker for syncing report_type approval_rules approvals_required
#
class SyncSecurityReportsToReportApprovalRulesWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: 3
  include SecurityScansQueue

  urgency :high
  worker_resource_boundary :cpu

  def perform(pipeline_id)
    pipeline = Ci::Pipeline.find_by_id(pipeline_id)
    return unless pipeline

    ::Security::SyncReportsToApprovalRulesService.new(pipeline).execute
  end
end
