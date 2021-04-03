# frozen_string_literal: true

module Security
  # Service for getting the scanned resources for
  # an array of report types within a pipeline
  #
  class ScannedResourcesService
    # @param [Ci::Pipeline] pipeline
    # @param Array[Symbol] report_types Summary report types. Valid values are members of Enums::Vulnerability.report_types
    # @param [Int] The maximum number of scanned resources to return
    def initialize(pipeline, report_types, limit = nil)
      @pipeline = pipeline
      @report_types = report_types
      @limit = limit
    end

    def execute
      reports = @pipeline&.security_reports&.reports || {}
      @report_types.each_with_object({}) do |type, acc|
        scanned_resources = reports[type]&.scanned_resources || []
        scanned_resources = scanned_resources.first(@limit) if @limit
        acc[type] = scanned_resources.map do |resource|
          {
            'request_method' => resource.request_method,
            'url' => resource.request_uri.to_s
          }
        end
      end
    end
  end
end
