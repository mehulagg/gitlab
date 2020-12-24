# frozen_string_literal: true

module Security
  class StoreScansWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include SecurityScansQueue

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(pipeline_id)
      ::Ci::Pipeline.find_by(id: pipeline_id).try do |pipeline|
        logger.info "Security::StoreScansWorker: store scans for pipeline: #{pipeline.id}"

        break unless pipeline.can_store_security_reports?

        Security::StoreScansService.execute(pipeline)
        security_build = secret_detection_build(pipeline)

        logger.info "Security::StoreScansWorker: no security_build found for pipeline: #{pipeline.id}" if security_build.nil?

        if revoke_secret_detection_token?(security_build)
          logger.info "Security::StoreScansWorker: token revocation started for pipeline: #{pipeline.id}"
          ::ScanSecurityReportSecretsWorker.perform_async(security_build.id)
        else
          logger.info "Security::StoreScansWorker: failed to revoke token for pipeline: #{pipeline.id}"
        end
      end
    end

    private

    def secret_detection_build(pipeline)
      pipeline.security_scans.secret_detection.last&.build
    end

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
