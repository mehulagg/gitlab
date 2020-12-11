# frozen_string_literal: true

module Security
  class MergeReportsService
    def initialize(*source_reports)
      @source_reports = source_reports
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
          Enums::Vulnerability.severity_levels[b_severity] <=>
            Enums::Vulnerability.severity_levels[a_severity]
        end
      end
    end

    def copy_findings_to_target
      deduplicate_findings!
      sort_findings!

      @findings.each { |finding| @target_report.add_finding(finding) }
    end
  end
end

Security::MergeReportsService.prepend_if_ee('EE::Security::MergeReportsService')
