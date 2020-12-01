# frozen_string_literal: true

module Geo
  class FrameworkRepositoryDestroyWorker
    include ApplicationWorker
    include GeoQueue
    include ::Gitlab::Geo::LogHelpers

    idempotent!

    loggable_arguments 0

    def perform(replicable_name, replicable_id)
      log_info('Executing Geo::FrameworkRepositoryDestroyWorker', replicable_id: replicable_id, replicable_name: replicable_name)

      replicator = Gitlab::Geo::Replicator.for_replicable_params(replicable_name: replicable_name, replicable_id: replicable_id)

      ::Geo::RepositoryRegistryRemovalService.new(replicator).execute
    end
  end
end
