# frozen_string_literal: true

class BulkImportWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :importers

  sidekiq_options retry: false, dead: false

  worker_has_external_dependencies!

  def perform(bulk_import_id)
    @bulk_import = BulkImport.find_by_id(bulk_import_id)

    return unless @bulk_import

    top_level_group_entities.each { |entity| BulkImports::SubgroupEntitiesCreator.new(entity.id).execute }

    # while (group_entity = next_eligible_group)
    #   group_entity.start!
    #
    #   BulkImports::Importers::GroupImporter.new(group_entity.id).execute
    #
    #   group_entity.finish!
    # end

    # @bulk_import.finish!
  end

  private

  def next_eligible_group

  end

  def top_level_group_entities
    @bulk_import.entities.where(parent_id: nil, source_type: 'group_entity') # rubocop: disable CodeReuse/ActiveRecord
  end
end
