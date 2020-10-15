# frozen_string_literal: true

module BulkImports
  class ImportGroupWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include QueueOptions

    worker_has_external_dependencies!

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(bulk_import_id, entity_id, waiter_key = nil)
      bulk_import = BulkImport.find(bulk_import_id)

      return notify_waiter(waiter_key) unless bulk_import

      entity = BulkImports::Entity.find_by(bulk_import_id: bulk_import_id, id: entity_id)

      entity.jid = self.jid
      entity.start!

      Importers::GroupImporter.new(entity_id).execute

      entity.finish!
      notify_waiter(waiter_key)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def notify_waiter(key = nil)
      Gitlab::JobWaiter.notify(key, jid) if key
    end
  end
end
