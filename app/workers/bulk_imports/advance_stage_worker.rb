# frozen_string_literal: true

module BulkImports
  class AdvanceStageWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include QueueOptions

    INTERVAL = 30.seconds.to_i.freeze
    BLOCKING_WAIT_TIME = 5.seconds.to_i.freeze

    STAGES = {
      groups: Stage::ImportGroupsWorker,
      finish: Stage::FinishImportWorker
    }.freeze

    def perform(bulk_import_id, waiters, next_stage)
      new_waiters = wait_for_jobs(waiters)

      if new_waiters.empty?
        next_stage_worker(next_stage).perform_async(bulk_import_id)
      else
        self.class.perform_in(INTERVAL, bulk_import_id, new_waiters, next_stage)
      end
    end

    def wait_for_jobs(waiters)
      waiters.each_with_object({}) do |(key, remaining), new_waiters|
        waiter = Gitlab::JobWaiter.new(remaining, key)

        waiter.wait(BLOCKING_WAIT_TIME)

        next unless waiter.jobs_remaining > 0

        new_waiters[waiter.key] = waiter.jobs_remaining
      end
    end

    private

    def next_stage_worker(next_stage)
      STAGES.fetch(next_stage.to_sym)
    end
  end
end
