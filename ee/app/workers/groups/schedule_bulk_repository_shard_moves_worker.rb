# frozen_string_literal: true

module Groups
  class ScheduleBulkRepositoryShardMovesWorker
    include ApplicationWorker

    sidekiq_options retry: 3

    idempotent!
    feature_category :gitaly
    urgency :throttled

    def perform(source_storage_name, destination_storage_name = nil)
      Groups::ScheduleBulkRepositoryShardMovesService.new.execute(source_storage_name, destination_storage_name)
    end
  end
end
