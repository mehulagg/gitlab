# frozen_string_literal: true

module Security
  class MergeReportsService
    ANALYZER_ORDER = {
      "bundler_audit" => 1,
      "retire.js" =>  2,
      "gemnasium" => 3,
      "gemnasium-maven" => 3,
      "gemnasium-python" => 3,
      "unknown" => 999
    }.freeze

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

    def execute
      @source_reports.each do |source|
        copy_scanners_to_target(source)
        copy_identifiers_to_target(source)
        copy_findings_to_buffer(source)
        copy_scanned_resources_to_target(source)
      end

      copy_findings_to_target

      @target_report
    end

    private

    def copy_scanners_to_target(source_report)
      # no need for de-duping: it's done by Report internally
      source_report.scanners.values.each { |scanner| @target_report.add_scanner(scanner) }
    end

    def copy_identifiers_to_target(source_report)
      # no need for de-duping: it's done by Report internally
      source_report.identifiers.values.each { |identifier| @target_report.add_identifier(identifier) }
    end

    def copy_findings_to_buffer(source)
      @findings.concat(source.findings)
    end

    def copy_scanned_resources_to_target(source_report)
      @target_report.scanned_resources.concat(source_report.scanned_resources).uniq!
    end

    def deduplicate_findings!
      @findings, * = @findings.each_with_object([[], Set.new]) do |finding, (deduplicated, seen_identifiers)|
        next if seen_identifiers.intersect?(finding.keys.to_set)

        seen_identifiers.merge(finding.keys)
        deduplicated << finding
      end
    end

    def sort_findings!
      @findings.sort! do |a, b|
        a_severity, b_severity = a.severity, b.severity

        if a_severity == b_severity
          a.compare_key <=> b.compare_key
        else
          Vulnerabilities::Finding::SEVERITY_LEVELS[b_severity] <=>
            Vulnerabilities::Finding::SEVERITY_LEVELS[a_severity]
        end
      end
    end

    def copy_findings_to_target
      deduplicate_findings!
      sort_findings!

      @findings.each { |finding| @target_report.add_finding(finding) }
    end

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
