# frozen_string_literal: true

module BulkImports
  class PipelineWorker
    include ApplicationWorker

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    def perform(entity_id, pipeline_name, notify_key)
      Gitlab::Import::Logger.info(
        worker: :pipeline_worker,
        pipeline_name: pipeline_name,
        notify_key: notify_key
      )
      pipeline_class = pipeline_name.constantize
      entity = BulkImports::Entity.with_status(:started).find_by_id(entity_id)
      context = BulkImports::Pipeline::Context.new(entity)

      pipeline_class.new.run(context)
    ensure
      ::Gitlab::JobWaiter.notify(notify_key, jid)
    end
  end
end
