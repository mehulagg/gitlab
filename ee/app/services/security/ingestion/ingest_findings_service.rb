# frozen_string_literal: true

module Security
  module Ingestion
    class IngestFindingsService
      FINDING_ATTRIBUTES = %i[confidence metadata_version name raw_metadata report_type severity details].freeze
      RAW_METADATA_ATTRIBUTES = %w[description message solution cve location].freeze
      UPSERT_RETURN_COLUMNS = %i[uuid id vulnerability_id]

      def initialize(security_scan, identifiers_map)
        @security_scan = security_scan
        @identifiers_map = identifiers_map
      end

      def execute
        ingest_findings.each_with_object({}) do |tuple, memo|
          memo[tuple.shift] = tuple
        end
      end

      private

      attr_reader :security_scan, :identifiers_map

      delegate :project, :report_findings, to: :security_scan, private: true

      def ingest_findings
        Vulnerabilities::Finding.upsert_all(finding_attributes, returning: UPSERT_RETURN_COLUMNS, unique_by: :uuid).rows
      end

      def finding_attributes
        security_findings.map { |security_finding| [security_finding, report_findings_map.fetch(security_finding.uuid)] }
                         .map { |args| attributes_for(*args) }
      end

      def security_findings
        security_scan.findings.deduplicated
      end

      def report_findings_map
        @report_findings_map ||= report_findings.index_by(&:uuid)
      end

      def attributes_for(security_finding, report_finding)
        # This is horrible! We should address this with a follow-up
        parsed_from_raw_metadata = Gitlab::Json.parse(report_finding.raw_metadata).slice(RAW_METADATA_ATTRIBUTES)

        report_finding.to_hash
                      .slice(*FINDING_ATTRIBUTES)
                      .merge(parsed_from_raw_metadata)
                      .merge(primary_identifier_id: identifiers_map[report_finding.primary_identifier_fingerprint], location_fingerprint: report_finding.location.fingerprint, project_fingerprint: report_finding.project_fingerprint)
                      .merge(uuid: security_finding.uuid, project_id: project.id, scanner_id: security_finding.scanner_id)
                      .merge(created_at: Time.zone.now, updated_at: Time.zone.now)
      end

      # Scanners are already created by the `StoreScansWorker`
      def scanners
        @scanners ||= project.vulnerability_scanners.index_by(:external_id)
      end
    end
  end
end
