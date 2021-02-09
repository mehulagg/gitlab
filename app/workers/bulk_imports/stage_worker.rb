# frozen_string_literal: true

module BulkImports
  class StageWorker
    include ApplicationWorker
    INTERVAL = 30.seconds.to_i

    feature_category :importers

    sidekiq_options retry: false, dead: false

    worker_has_external_dependencies!

    def perform(entity_id, stages, waiter: nil)
      Gitlab::Import::Logger.info(
        worker: :stage_worker,
        stages: stages,
        waiter: waiter
      )
      return if stages.empty? && waiter.nil? # all stages finished

      if waiter # stage started
        if waiter.jobs_remaining > 0 # stage still running
          wait(entity_id, stages, waiter: waiter)
        else # stage finished
          run_next_stage(entity_id, stages)
        end
      else # no stage running
        run_stage_pipelines(entity_id, stages)
        wait(entity_id, stages, waiter: waiter)
      end
    end

    private

    def run_stage_pipelines(entity_id, stages)
      stage = Array.wrap(stages[0])
      waiter = ::Gitlab::JobWaiter.new(stage.size, worker_label: :bulk_import_stage)

      Gitlab::Import::Logger.info(
        message: 'run stage pipelines',
        stage: stage,
        waiter: waiter
      )

      stage.each do |pipeline| # start each pipeline of the stage
        BulkImports::PipelineWorker.perform_async(entity_id, pipeline, waiter.key)
      end
    end

    def run_next_stage(entity_id, stages)
      Gitlab::Import::Logger.info(
        message: 'stage finished',
        stage: stages[0]
      )

      next_stages = stages[1..-1]
      self.class.perform_async(entity_id, next_stages)
    end

    def wait(entity_id, stages, waiter:)
      Gitlab::Import::Logger.info(
        message: 'waiting stage',
        stage: stages[0],
        waiter: waiter
      )

      self.class.perform_in(INTERVAL, entity_id, stages, waiter: waiter)
    end
  end
end
