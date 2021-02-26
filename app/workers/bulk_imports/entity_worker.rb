# frozen_string_literal: true

module BulkImports
  class EntityWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    feature_category :importers

    deduplicate :until_executed
    idempotent!
    worker_has_external_dependencies!

    def perform(entity_id)
      entity = BulkImports::Entity.with_status(:created).find_by_id(entity_id)

      if entity
        entity.update!(status_event: 'start', jid: jid)

        BulkImports::Importers::GroupImporter.new(entity).execute
      end
    rescue => e
      extra = {
        bulk_import_id: entity&.bulk_import&.id,
        entity_id: entity&.id
      }

      Gitlab::ErrorTracking.track_exception(e, extra)

      entity&.fail_op
    end
  end
end
