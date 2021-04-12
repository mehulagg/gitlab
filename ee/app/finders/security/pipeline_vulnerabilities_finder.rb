# frozen_string_literal: true

# Security::PipelineVulnerabilitiesFinder
#
# Used to retrieve security vulnerabilities from an associated Pipeline,
# This involves normalizing Report::Occurrence POROs to Vulnerabilities::Finding
#
# Arguments:
#   pipeline - object to filter vulnerabilities
#   params:
#     report_type: Array<String>

module Security
  class PipelineVulnerabilitiesFinder
    include Gitlab::Utils::StrongMemoize
    ParseError = Class.new(Gitlab::Ci::Parsers::ParserError)

    attr_accessor :params
    attr_reader :pipeline

    def initialize(pipeline:, params: {})
      @pipeline = pipeline
      @params = params
    end

    def execute
      findings = requested_reports.each_with_object([]) do |(type, report), findings|
        raise ParseError, 'JSON parsing failed' if report.error.is_a?(Gitlab::Ci::Parsers::Security::Common::SecurityReportParserError)

        normalized_findings = normalize_report_findings(
          report.findings,
          vulnerabilities_by_finding_fingerprint(type, report))
        filtered_findings = filter(normalized_findings)

        findings.concat(filtered_findings)
      end

      Gitlab::Ci::Reports::Security::AggregatedReport.new(requested_reports.values, sort_findings(findings))
    end

    private

    def sort_findings(findings)
      # This sort is stable (see https://en.wikipedia.org/wiki/Sorting_algorithm#Stability) contrary to the bare
      # Ruby sort_by method. Using just sort_by leads to instability across different platforms (e.g., x86_64-linux and
      # x86_64-darwin18) which in turn leads to different sorting results for the equal elements across these platforms.
      # This is important because it breaks test suite results consistency between local and CI
      # environment.
      # This is easier to address from within the class rather than from tests because this leads to bad class design
      # and exposing too much of its implementation details to the test suite.
      # See also https://stackoverflow.com/questions/15442298/is-sort-in-ruby-stable.
      Gitlab::Utils.stable_sort_by(findings) { |x| [-x.severity_value, -x.confidence_value] }
    end

    def requested_reports
      @requested_reports ||= pipeline&.security_reports(report_types: report_types)&.reports || {}
    end

    def vulnerabilities_by_finding_fingerprint(report_type, report)
      Vulnerabilities::Finding
        .by_project_fingerprints(report.findings.map(&:project_fingerprint))
        .by_projects(pipeline.project)
        .by_report_types(report_type)
        .select(:vulnerability_id, :project_fingerprint)
       .each_with_object({}) do |finding, hash|
        hash[finding.project_fingerprint] = finding.vulnerability_id
      end
    end

    # This finder is used for fetching vulnerabilities for any pipeline, if we used it to fetch
    # vulnerabilities for a non-default-branch, the findings will be unpersisted, so we
    # coerce the POROs into unpersisted AR records to give them a common object.
    # See https://gitlab.com/gitlab-org/gitlab/issues/33588#note_291849433 for more context
    # on why this happens.
    def normalize_report_findings(report_findings, vulnerabilities)
      report_findings.map do |report_finding|
        finding_hash = report_finding.to_hash
          .except(:compare_key, :identifiers, :location, :scanner, :links, :signatures)

        finding = Vulnerabilities::Finding.new(finding_hash)
        # assigning Vulnerabilities to Findings to enable the computed state
        finding.location_fingerprint = report_finding.location.fingerprint
        finding.vulnerability_id = vulnerabilities[finding.project_fingerprint]
        finding.project = pipeline.project
        finding.sha = pipeline.sha
        finding.build_scanner(report_finding.scanner&.to_hash)
        finding.finding_links = report_finding.links.map do |link|
          Vulnerabilities::FindingLink.new(link.to_hash)
        end
        finding.identifiers = report_finding.identifiers.map do |identifier|
          Vulnerabilities::Identifier.new(identifier.to_hash)
        end
        finding.signatures = report_finding.signatures.map do |signature|
          Vulnerabilities::FindingSignature.new(signature.to_hash)
        end

        finding
      end
    end

    def filter(findings)
      findings.select do |finding|
        next if !include_dismissed? && dismissal_feedback?(finding)
        next unless confidence_levels.include?(finding.confidence)
        next unless severity_levels.include?(finding.severity)
        next if scanners.present? && !scanners.include?(finding.scanner.external_id)

        finding
      end
    end

    def include_dismissed?
      params[:scope] == 'all'
    end

    def dismissal_feedback?(finding)
      if ::Feature.enabled?(:vulnerability_finding_signatures, pipeline.project) && !finding.signatures.empty?
        dismissal_feedback_by_finding_signatures(finding)
      else
        dismissal_feedback_by_project_fingerprint(finding)
      end
    end

    def all_dismissal_feedbacks
      strong_memoize(:all_dismissal_feedbacks) do
        pipeline.project
          .vulnerability_feedback
          .for_dismissal
      end
    end

    def dismissal_feedback_by_finding_signatures(finding)
      potential_uuids = Set.new([*finding.signature_uuids, finding.uuid].compact)
      all_dismissal_feedbacks.any? { |dismissal| potential_uuids.include?(dismissal.finding_uuid) }
    end

    def dismissal_feedback_by_fingerprint
      strong_memoize(:dismissal_feedback_by_fingerprint) do
        all_dismissal_feedbacks.group_by(&:project_fingerprint)
      end
    end

    def dismissal_feedback_by_project_fingerprint(finding)
      dismissal_feedback_by_fingerprint[finding.project_fingerprint]
    end

    def confidence_levels
      Array(params.fetch(:confidence, Vulnerabilities::Finding.confidences.keys))
    end

    def report_types
      Array(params.fetch(:report_type, Vulnerabilities::Finding.report_types.keys))
    end

    def severity_levels
      Array(params.fetch(:severity, Vulnerabilities::Finding.severities.keys))
    end

    def scanners
      Array(params.fetch(:scanner, []))
    end
  end
end
