# frozen_string_literal: true

module Geo
  class SnippetRepositoryReplicator < Gitlab::Geo::Replicator
    include ::Geo::RepositoryReplicatorStrategy

    def self.model
      ::SnippetRepository
    end

    def self.replication_enabled_by_default?
      false
    end

    def needs_checksum?
      false
    end

    def repository
      model_record.repository
    end

    # Once https://gitlab.com/gitlab-org/gitlab/-/issues/213021 is fixed
    # this method can be removed
    def remote_url
      url = Gitlab::Geo.primary_node.repository_url(repository)
      url.sub('@snippets', 'snippets')
    end

    # Once https://gitlab.com/gitlab-org/gitlab/-/issues/213021 is fixed
    # this method can be removed
    def jwt_authentication_header
      authorization = ::Gitlab::Geo::RepoSyncRequest.new(
        scope: repository.full_path.sub('@snippets', 'snippets')
      ).authorization

      { "http.#{remote_url}.extraHeader" => "Authorization: #{authorization}" }
    end
  end
end
