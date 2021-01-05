# frozen_string_literal: true

# Worker for storing security reports into the database.
#
class StoreSecurityReportsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include SecurityScansQueue

  tags :requires_disk_io

  def perform(pipeline_id)
    Ci::Pipeline.find(pipeline_id).try do |pipeline|
      break unless pipeline.project.can_store_security_reports?

      ::Security::StoreReportsService.new(pipeline).execute

      if revoke_secret_detection_token?(pipeline)
        ::ScanSecurityReportSecretsWorker.perform_async(pipeline.id)
      end
    end
  end

  private

  def revoke_secret_detection_token?(pipeline)
    pipeline.present? &&
      ::Gitlab::CurrentSettings.secret_detection_token_revocation_enabled? &&
      secret_detection_vulnerability_found?(pipeline)
  end

  def secret_detection_vulnerability_found?(pipeline)
    pipeline.vulnerability_findings.secret_detection.any?
  end
end
