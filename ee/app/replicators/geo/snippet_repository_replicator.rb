# frozen_string_literal: true

module Geo
  class SnippetRepositoryReplicator < Gitlab::Geo::Replicator
    include ::Geo::RepositoryReplicatorStrategy
    extend ::Gitlab::Utils::Override

    def self.model
      ::SnippetRepository
    end

    def self.git_access_class
      ::Gitlab::GitAccessSnippet
    end

    override :verification_feature_flag_enabled?
    def self.verification_feature_flag_enabled?
      Feature.enabled?(:geo_snippet_repository_verification, default_enabled: :yaml)
    end

    def repository
      model_record.repository
    end
  end
end
