# frozen_string_literal: true

module BulkImports
  class PipelineWorker
    include ApplicationWorker

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    TIMEOUT = 3.seconds

    def perform(entity_id)
      pipelines = BulkImports::EntityPipelineStatus.where(
        bulk_import_entity_id: entity_id,
        status: :created
      ).order(:stage_name).limit(5) # TODO

      return if pipelines.blank?

      entity = BulkImports::Entity.find(entity_id)
      context = BulkImports::Pipeline::Context.new(entity)

      pipelines.each do |pipeline|
        pipeline.new(context).run
      end

      self.class.perform_in(TIMEOUT, entity_id)
    end
  end
end
