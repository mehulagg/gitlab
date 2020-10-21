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

    IdentifierKey = Struct.new(:location_sha, :identifier_type, :identifier_value) do
      def ==(other)
        location_sha == other.location_sha &&
          identifier_type == other.identifier_type &&
          identifier_value == other.identifier_value
      end

      def hash
        location_sha.hash ^ identifier_type.hash ^ identifier_value.hash
      end

      alias_method :eql?, :==
    end

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

    # this method mutates the passed seen_identifiers set
    def check_or_mark_seen_identifier!(identifier, location_fingerprint, seen_identifiers)
      key = IdentifierKey.new(location_fingerprint, identifier.external_type, identifier.external_id)

      if seen_identifiers.include?(key)
        true
      else
        seen_identifiers.add(key)
        false
      end
    end

    def deduplicate_findings!
      seen_identifiers = Set.new
      deduplicated = []

      @findings.each do |finding|
        seen = false

        # We are looping through all identifiers in order to find the same vulnerabilities reported for the same location
        # but from different source reports and keeping only first of them
        finding.identifiers.each do |identifier|
          # TODO: remove .downcase here after the DAST parser is harmonized to the common library identifiers' keys format
          # See https://gitlab.com/gitlab-org/gitlab/issues/11976#note_191257912
          next if %w[cwe wasc].include?(identifier.external_type.downcase) # ignored because these describe a class of vulnerabilities

          seen = check_or_mark_seen_identifier!(identifier, finding.location.fingerprint, seen_identifiers)

          break if seen
        end

        deduplicated << finding unless seen
      end

      @findings = deduplicated
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
