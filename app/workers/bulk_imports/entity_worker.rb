# frozen_string_literal: true

module BulkImports
  class EntityWorker # rubocop: disable Scalability/IdempotentWorker
    include ApplicationWorker

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    def perform(entity_id, waiter_key)
      entity = BulkImports::Entity.find(entity_id)

      BulkImports::Importers::GroupImporter.new(entity).execute
    ensure
      ::Gitlab::JobWaiter.notify(waiter_key, jid)
    end
  end
end
