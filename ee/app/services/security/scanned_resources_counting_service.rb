# frozen_string_literal: true

module Security
  # Service for counting the number of scanned resources for
  # an array of report types within a pipeline
  #
  class ScannedResourcesCountingService
    # @param [Ci::Pipeline] pipeline
    # @param Array[Symbol] report_types Summary report types. Valid values are members of Enums::Vulnerability.report_types
    def initialize(pipeline, report_types)
      @pipeline = pipeline
      @report_types = report_types
    end

    def execute
      scanned_resources = ::Security::ScannedResourcesService.new(@pipeline, @report_types).execute
      scanned_resources.transform_values do |scanned_resources|
        scanned_resources.length
      end
    end
  end
end
