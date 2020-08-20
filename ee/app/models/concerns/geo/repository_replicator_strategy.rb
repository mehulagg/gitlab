# frozen_string_literal: true

module Geo
  module RepositoryReplicatorStrategy
    extend ActiveSupport::Concern

    include Delay
    include Gitlab::Geo::LogHelpers

    included do
      event :updated
      event :deleted
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_updated(**params)
      return unless in_replicables_for_geo_node?

      sync_repository
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_deleted(**params)
      replicate_destroy(params)
    end

    def replicate_destroy(params)
      Geo::RepositoryRegistryRemovalService.new(params.merge(replicable_name: replicable_name)).execute
    end

    def sync_repository
      Geo::FrameworkRepositorySyncService.new(replicator: self).execute
    end

    def reschedule_sync
      Geo::EventWorker.perform_async(replicable_name, 'updated', { model_record_id: model_record.id })
    end

    def remote_url
      Gitlab::Geo.primary_node.repository_url(repository)
    end

    def jwt_authentication_header
      authorization = ::Gitlab::Geo::RepoSyncRequest.new(
        scope: repository.full_path
      ).authorization

      { "http.#{remote_url}.extraHeader" => "Authorization: #{authorization}" }
    end

    def deleted_params
      event_params.merge(
        repository_storage: model_record.repository_storage,
        disk_path: model_record.repository.disk_path
      )
    end
  end
end
