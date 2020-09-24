# frozen_string_literal: true

module Geo
  class SnippetRepositoryReplicator < Gitlab::Geo::Replicator
    include ::Geo::RepositoryReplicatorStrategy

    def self.model
      ::SnippetRepository
    end

    def needs_checksum?
      false
    end

    def self.replication_enabled_by_default?
      false
    end
  end
end
