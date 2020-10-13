# frozen_string_literal: true

module Security
  # Service for storing security reports into the database.
  #
  class StoreReportsService < ::BaseService
    def initialize(pipeline)
      @pipeline = pipeline
    end

    def execute
      errors = []
      @pipeline.security_reports.reports.each do |report_type, report|
        result = StoreReportService.new(@pipeline, report).execute
        errors << result[:message] if result[:status] == :error
      end

      if errors.any?
        error(errors.join(", "))
      else
        success
      end
    end
  end
end
