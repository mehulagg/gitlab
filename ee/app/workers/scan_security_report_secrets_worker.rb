# frozen_string_literal: true

# Worker for triggering events subject to secret_detection security reports
#
class ScanSecurityReportSecretsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # TODO: set dedicated queue
  include SecurityScansQueue

  urgency :high
  worker_resource_boundary :cpu

  def perform(build_id)
    build = Ci::Build.find_by_id(build_id)
    return unless build

    report = build.security_reports.find(&:secret_detection?)
    if report && report.unsafe? && !report.revocable_keys.empty?
      TokenRevocationService.new(build_id: build.id, revocable_keys: report.revocable_keys).execute
      NotificationService.new.security_report_alert_on_push_to_merge_request(build)
    end
  end
end
