# frozen_string_literal: true

# Worker for triggering events subject to secret_detection security reports
#
class ScanSecurityReportSecretsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include SecurityScansQueue

  worker_resource_boundary :cpu

  sidekiq_options retry: 20

  worker_has_external_dependencies!
  idempotent!

  ScanSecurityReportSecretsWorkerError = Class.new(StandardError)

  def perform(build_id)
    build = Ci::Build.find_by_id(build_id)
    return unless build

    keys = revocable_keys(build)

    if keys.present?
      executed_result = Security::TokenRevocationService.new(revocable_keys: keys).execute

      raise ScanSecurityReportSecretsWorkerError, executed_result[:message] if executed_result[:status] == :error
    end
  end

  private

  def revocable_keys(build)
    vulnerability_findings = build.pipeline.vulnerability_findings.report_type(:secret_detection)

    vulnerability_findings.map do |vulnerability_finding|
      {
        type: revocation_type(vulnerability_finding),
        token: vulnerability_finding.metadata['raw_source_code_extract'],
        location: vulnerability_finding.vulnerability.present.location_link
      }
    end
  end

  def revocation_type(vulnerability_finding)
    identifier = vulnerability_finding.metadata['identifiers'].first
    (identifier["type"] + '_' + identifier["value"].tr(' ', '_')).downcase
  end
end
