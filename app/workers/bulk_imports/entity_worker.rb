# frozen_string_literal: true

module BulkImports
  class EntityWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    def perform(entity_id, current_stage = nil)
      logger.info(
        worker: self.class.name,
        entity_id: entity_id,
        current_stage: current_stage
      )

      return if stage_running?(entity_id, current_stage)

      next_stage_for(entity_id).each do |pipeline_tracker|
        BulkImports::PipelineWorker.perform_async(
          entity_id,
          pipeline_tracker.id
        )
      end
    rescue => e
      logger.error(
        worker: self.class.name,
        entity_id: entity_id,
        current_stage: current_stage,
        error_message: e.message
      )

      Gitlab::ErrorTracking.track_exception(e, entity_id: entity_id)
    end

    private

    def stage_running?(entity_id, stage)
      return unless stage

      BulkImports::Tracker.stage_running?(entity_id, stage)
    end

    def next_stage_for(entity_id)
      BulkImports::Tracker.next_stage_for(entity_id)
    end

    def logger
      @logger ||= Gitlab::Import::Logger
    end
  end
end
