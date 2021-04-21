# frozen_string_literal: true

module Security
  class MergeReportsService
    ANALYZER_ORDER = {
      "bundler_audit" => 1,
      "retire.js" =>  2,
      "gemnasium" => 3,
      "gemnasium-maven" => 3,
      "gemnasium-python" => 3,
      "bandit" => 1,
      "semgrep" =>  2,
      "unknown" => 999
    }.freeze

    def initialize(*source_reports)
      @source_reports = source_reports

      sort_by_analyzer_order!

      @target_report = ::Gitlab::Ci::Reports::Security::Report.new(
        @source_reports.first.type,
        @source_reports.first.pipeline,
        @source_reports.first.created_at
      ).tap { |report| report.errors = source_reports.flat_map(&:errors) }
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
        a_severity = a.severity
        b_severity = b.severity

        if a_severity == b_severity
          a.compare_key <=> b.compare_key
        else
          ::Enums::Vulnerability.severity_levels[b_severity] <=>
            ::Enums::Vulnerability.severity_levels[a_severity]
        end
      end
    end

    def copy_findings_to_target
      deduplicate_findings!
      sort_findings!

      @findings.each { |finding| @target_report.add_finding(finding) }
    end

    def reports_sortable?
      return true if @source_reports.all? { |x| x.type == :dependency_scanning }
      return true if @source_reports.all? { |x| x.type == :sast }

      false
    end

    def sort_by_analyzer_order!
      return unless reports_sortable?

      @source_reports.sort! do |a, b|
        a_scanner_id = a.scanners.values[0].external_id
        b_scanner_id = b.scanners.values[0].external_id

        a_scanner_id = "unknown" if ANALYZER_ORDER[a_scanner_id].nil?
        b_scanner_id = "unknown" if ANALYZER_ORDER[b_scanner_id].nil?

        ANALYZER_ORDER[a_scanner_id] <=> ANALYZER_ORDER[b_scanner_id]
      end
    end
  end
end
