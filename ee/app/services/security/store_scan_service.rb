# frozen_string_literal: true

# This service stores the `Security::Scan` and
# `Security::Finding` records for the given job artifact.
#
# @param artifact [Ci::JobArtifact] the artifact to create scan and finding records from.
# @param known_keys [Set] the set of known finding keys stored by previous invocations of this service class.
# @param deduplicate [Boolean] attribute to force running deduplication logic.
module Security
  class StoreScanService < ::BaseService
    def self.execute(artifact, known_keys, deduplicate)
      new(artifact, known_keys, deduplicate).execute
    end

    def initialize(artifact, known_keys, deduplicate)
      @artifact = artifact
      @known_keys = known_keys
      @deduplicate = deduplicate
    end

    def execute
      StoreFindingsMetadataService.execute(security_scan, security_report)
      deduplicate_findings? ? update_deduplicated_findings : register_finding_keys

      deduplicate_findings?
    end

    private

    attr_reader :artifact, :known_keys, :deduplicate
    delegate :security_report, to: :artifact, private: true

    def security_scan
      @security_scan ||= Security::Scan.safe_find_or_create_by!(build: artifact.job, scan_type: artifact.file_type)
    end

    def deduplicate_findings?
      deduplicate || security_scan.saved_changes?
    end

    def update_deduplicated_findings
      ActiveRecord::Base.transaction do
        security_scan.findings.update_all(deduplicated: false)

        security_scan.findings
                     .by_project_fingerprint(deduplicated_project_fingerprints)
                     .update_all(deduplicated: true)
      end
    end

    def deduplicated_project_fingerprints
      register_finding_keys.map(&:project_fingerprint)
    end

    def register_finding_keys
      @register_finding_keys ||= security_report.findings.select { |finding| register_keys(finding.keys) }
    end

    def register_keys(keys)
      keys.map { |key| known_keys.add?(key) }.all?
    end
  end
end
