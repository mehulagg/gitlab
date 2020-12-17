# frozen_string_literal: true

module Security
  class StoreScansWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include SecurityScansQueue

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(pipeline_id)
      ::Ci::Pipeline.find_by(id: pipeline_id).try do |pipeline|
        break unless pipeline.can_store_security_reports?

        Security::StoreScansService.execute(pipeline)
        secret_detection_build = pipeline.security_scans.secret_detection.first&.build

        if revoke_secret_detection_token?(secret_detection_build)
          ::ScanSecurityReportSecretsWorker.perform_async(secret_detection_build.id)
        end
      end
    end

    private

    def revoke_secret_detection_token?(build)
      build.present? &&
        ::Gitlab::CurrentSettings.secret_detection_token_revocation_enabled? &&
        secret_detection_vulnerability_found?(build)
    end

    def secret_detection_vulnerability_found?(build)
      build.pipeline.vulnerability_findings.secret_detection.any?
    end
  end
end
