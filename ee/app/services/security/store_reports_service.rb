# frozen_string_literal: true

module Security
  # Service for storing security reports into the database.
  #
  class StoreReportsService < ::BaseService
    def initialize(pipeline)
      @pipeline = pipeline
      @errors = []
    end

    def execute
      store_reports
      mark_project_as_vulnerable!
      set_latest_pipeline!

      errors.any? ? error(full_errors) : success
    end

    private

    attr_reader :pipeline, :errors

    delegate :project, to: :pipeline, private: true

    def store_reports
      pipeline.security_reports.reports.each do |report_type, report|
        result = StoreReportService.new(pipeline, report).execute
        errors << result[:message] if result[:status] == :error

        track_scan_event(report_type, report)
      end
    end

    def mark_project_as_vulnerable!
      project.project_setting.update!(has_vulnerabilities: true)
    end

    def set_latest_pipeline!
      Vulnerabilities::Statistic.set_latest_pipeline_with(pipeline)
    end

    def full_errors
      errors.join(", ")
    end

    def track_scan_event(report_type, report)
      ::Gitlab::Tracking.event(
        'secure::scan',
        'scan',
        end_time: report&.scan&.end_time,
        project: pipeline.project_id,
        scan_type: report&.scan&.type || report_type,
        start_time: report&.scan&.start_time,
        status: report&.scan&.status,
        triggered_by: pipeline.user_id,
        scanner: report&.primary_scanner&.external_id,
        scanner_vendor: report&.primary_scanner&.vendor,
      )
    end
  end
end
