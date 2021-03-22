# frozen_string_literal: true

module BulkImports
  class PipelineWorker
    include ApplicationWorker

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    def perform(entity_id, pipeline_tracker_id)
      pipeline_tracker = ::BulkImports::Tracker
        .with_status(:created)
        .find(pipeline_tracker_id)

      if pipeline_tracker.present?
        logger.info(
          worker: self.class.name,
          entity_id: pipeline_tracker.entity.id,
          pipeline_name: pipeline_tracker.pipeline_name
        )

        run(pipeline_tracker)
      else
        logger.error(
          worker: self.class.name,
          entity_id: entity_id,
          pipeline_name: pipeline_name,
          message: 'Pipeline does not exist'
        )
      end
    ensure
      ::BulkImports::EntityWorker.perform_async(entity_id, pipeline_tracker&.stage)
    end

    private

    def run(pipeline_tracker)
      pipeline_tracker.update!(status_event: 'start', jid: jid)

      context = ::BulkImports::Pipeline::Context.new(pipeline_tracker)
      pipeline_class = pipeline_tracker.pipeline_name.constantize

      pipeline_class.new(context).run

      pipeline_tracker.finish!
    rescue => e
      pipeline_tracker.fail_op!

      logger.error(
        worker: self.class.name,
        entity_id: pipeline_tracker.entity.id,
        pipeline_name: pipeline_tracker.pipeline_name,
        message: e.message
      )

      Gitlab::ErrorTracking.track_exception(
        e,
        entity_id: entity_id,
        pipeline_name: pipeline_tracker.pipeline_name
      )
    end

    def logger
      @logger ||= Gitlab::Import::Logger.build
    end
  end
end
