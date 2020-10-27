# frozen_string_literal: true

class BulkImportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :importers

  sidekiq_options retry: false, dead: false

  worker_has_external_dependencies!

  def perform(bulk_import_id)
    @bulk_import = BulkImport.find_by_id(bulk_import_id)

    return unless @bulk_import

    created_top_level_entities.each { |entity| BulkImports::SubgroupEntitiesCreator.new(entity.id).execute }

    while (group_entity = next_eligible_entity)
      group_entity.start!

      BulkImports::Importers::GroupImporter.new(group_entity.id).execute

      group_entity.finish!
    end

    @bulk_import.finish!
  end

  private

  def next_eligible_entity
    return created_top_level_entities.sample if created_top_level_entities.any?

    finished_entity_ids = finished_entities.pluck(:id)

    created_entities.with_parent(finished_entity_ids).sample
  end

  def created_entities
    @bulk_import.entities.groups.created
  end

  def finished_entities
    @bulk_import.entities.groups.finished
  end

  def created_top_level_entities
    created_entities.top_level
  end
end
