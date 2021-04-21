# frozen_string_literal: true

module Security
  class StoreGroupedScansService < ::BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    LEASE_TTL = 30.minutes
    LEASE_NAMESPACE = "store_grouped_scans"

    def self.execute(artifacts)
      new(artifacts).execute
    end

    def initialize(artifacts)
      @artifacts = artifacts
      @known_keys = Set.new
    end

    def execute
      in_lock(lease_key, ttl: LEASE_TTL) do
        sorted_artifacts.reduce(false) do |deduplicate, artifact|
          store_scan_for(artifact, deduplicate)
        end
      end
    rescue Gitlab::Ci::Parsers::ParserError => error
      Gitlab::ErrorTracking.track_exception(error)
    end

    private

    attr_reader :artifacts, :known_keys

    def lease_key
      "#{LEASE_NAMESPACE}:#{pipeline_id}:#{report_type}"
    end

    def pipeline_id
      artifacts.first&.job&.pipeline_id
    end

    def report_type
      artifacts.first&.file_type
    end

    def sorted_artifacts
      @sorted_artifacts ||= artifacts.sort_by { |artifact| [scanner_order_for(artifact), artifact.job.name] }
    end

    # This method returns the priority of scanners for dependency_scanning and sast
    # and `INFINITY` for all the other scan types. There is no problem with
    # calling this method for all the scan types to get rid of branching.
    def scanner_order_for(artifact)
      MergeReportsService::ANALYZER_ORDER.fetch(artifact.security_report(validate: true).primary_scanner&.external_id, Float::INFINITY)
    end

    def store_scan_for(artifact, deduplicate)
      StoreScanService.execute(artifact, known_keys, deduplicate)
    ensure
      artifact.clear_security_report
    end
  end
end
