# frozen_string_literal: true

module Geo
  class MergeRequestDiffReplicator < Gitlab::Geo::Replicator
    include ::Geo::BlobReplicatorStrategy

    def self.model
      ::MergeRequestDiff
    end

    def self.replication_enabled_by_default?
      false
    end

    def self.primary_total_count
      model.has_external_diffs.count
    end

    def carrierwave_uploader
      model_record.external_diff
    end
  end
end
