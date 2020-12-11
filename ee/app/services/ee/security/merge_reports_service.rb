# frozen_string_literal: true

module EE
  module Security
    module MergeReportsService
      extend ::Gitlab::Utils::Override

      ANALYZER_ORDER = {
        "bundler_audit" => 1,
        "retire.js" =>  2,
        "gemnasium" => 3,
        "gemnasium-maven" => 3,
        "gemnasium-python" => 3,
        "unknown" => 999
      }.freeze

      override :initialize
      def initialize(*source_reports)
        @source_reports = source_reports
        # temporary sort https://gitlab.com/gitlab-org/gitlab/-/issues/213839
        sort_by_ds_analyzers!
        @target_report = ::Gitlab::Ci::Reports::Security::Report.new(
          @source_reports.first.type,
          @source_reports.first.pipeline,
          @source_reports.first.created_at
        )
        @findings = []
      end

      private

      def sort_by_ds_analyzers!
        return if @source_reports.any? { |x| x.type != :dependency_scanning }

        @source_reports.sort! do |a, b|
          a_scanner_id, b_scanner_id = a.scanners.values[0].external_id, b.scanners.values[0].external_id

          # for custom analyzers
          a_scanner_id = "unknown" if ANALYZER_ORDER[a_scanner_id].nil?
          b_scanner_id = "unknown" if ANALYZER_ORDER[b_scanner_id].nil?

          ANALYZER_ORDER[a_scanner_id] <=> ANALYZER_ORDER[b_scanner_id]
        end
      end
    end
  end
end
