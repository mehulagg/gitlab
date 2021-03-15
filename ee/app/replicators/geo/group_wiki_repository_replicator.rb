# frozen_string_literal: true

module Geo
  class GroupWikiRepositoryReplicator < Gitlab::Geo::Replicator
    include ::Geo::RepositoryReplicatorStrategy

    def self.model
      ::GroupWikiRepository
    end

    def self.git_access_class
      ::Gitlab::GitAccessWiki
    end

    def repository
      model_record.repository
    end
  end
end
