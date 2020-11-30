# frozen_string_literal: true

module Geo
  class FrameworkDestroyWorker
    include ApplicationWorker
    include GeoQueue
    include ::Gitlab::Geo::LogHelpers

    idempotent!

    loggable_arguments 0

    def perform(replicable_name, replicable_id)
      log_info('Executing Geo::FrameworkDestroyWorker', replicable_id: replicable_id, replicable_name: replicable_name)

      replicator = Gitlab::Geo::Replicator.for_replicable_params(replicable_name: replicable_name, replicable_id: replicable_id)

      replicator.replicate_destroy({})
    end
  end
end
