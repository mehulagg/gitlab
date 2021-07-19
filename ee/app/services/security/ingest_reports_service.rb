# frozen_string_literal: true

module Security
  # Service for ingesting the security reports into the database.
  class IngestReportsService
    def self.execute(pipeline)

    end

    def initialize(pipeline)
      @pipeline = pipeline
    end

    def execute
      store_reports
      mark_project_as_vulnerable!
      set_latest_pipeline!
    end

    private

    attr_reader :pipeline

    delegate :project, to: :pipeline, private: true

    def latest_scans
      pipeline.security_scans.latest
    end

    def store_reports
      pipeline.security_reports.reports.each do |report_type, report|
        result = StoreReportService.new(pipeline, report).execute
        errors << result[:message] if result[:status] == :error
      end
    end

    def security_scans
      pipeline.security_scans
    end

    def mark_project_as_vulnerable!
      project.project_setting.update!(has_vulnerabilities: true)
    end

    def set_latest_pipeline!
      Vulnerabilities::Statistic.set_latest_pipeline_with(pipeline)
    end
  end
end
