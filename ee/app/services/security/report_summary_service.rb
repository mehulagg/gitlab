# frozen_string_literal: true

module Security
  class ReportSummaryService
    include Gitlab::Utils::StrongMemoize

    # @param [Ci::Pipeline] pipeline
    # @param [Hash[Symbol, Array[Symbol]] selection_information keys must be in the set of Vulnerabilities::Finding::REPORT_TYPES for example: {dast: [:scanned_resources_count, :vulnerabilities_count], container_scanning:[:vulnerabilities_count]}
    def initialize(pipeline, selection_information)
      @pipeline = pipeline
      @selection_information = selection_information
    end

    def execute
      @selection_information.each_with_object({}) do |(report_type, summary_types), response|
        response[report_type] = summary_counts_for_report_type(report_type, summary_types)
      end
    end

    private

    def summary_counts_for_report_type(report_type, summary_types)
      return unless report_exists?(report_type)

      summary_types.each_with_object({}) do |summary_type, response|
        case summary_type
        when :vulnerabilities_count
          response[:vulnerabilities_count] = vulnerability_counts[report_type.to_s]
        when :scanned_resources_count
          response[:scanned_resources_count] = scanned_resources_counts[report_type.to_s]
        when :scanned_resources
          response[:scanned_resources] = scanned_resources[report_type.to_s]
        when :scanned_resources_csv_path
          response[:scanned_resources_csv_path] = csv_path
        end
      end
    end

    def csv_path
      ::Gitlab::Routing.url_helpers.project_security_scanned_resources_path(
        @pipeline.project,
        format: :csv,
        pipeline_id: @pipeline.id)
    end

    def requested_report_types(summary_type)
      @report_types_for_summary_type ||= Gitlab::Utils.multiple_key_invert(@selection_information)
      @report_types_for_summary_type[summary_type].map(&:to_s)
    end

    def scanned_resources
      strong_memoize(:scanned_resources) do
        scanned_resources_limit = 20
        ::Security::ScannedResourcesService.new(@pipeline, requested_report_types(:scanned_resources), scanned_resources_limit).execute
      end
    end

    def vulnerability_counts
      strong_memoize(:vulnerability_counts) do
        ::Security::VulnerabilityCountingService.new(@pipeline, requested_report_types(:vulnerabilities_count)).execute
      end
    end

    def scanned_resources_counts
      strong_memoize(:scanned_resources_counts) do
        ::Security::ScannedResourcesCountingService.new(@pipeline, requested_report_types(:scanned_resources_count)).execute
      end
    end

    def report_exists?(report_type)
      @pipeline&.security_reports&.reports&.key?(report_type.to_s)
    end
  end
end
