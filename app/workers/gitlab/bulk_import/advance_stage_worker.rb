# frozen_string_literal: true

module Gitlab
  module BulkImport
    class AdvanceStageWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include QueueOptions

      INTERVAL = 30.seconds.to_i.freeze
      BLOCKING_WAIT_TIME = 5.seconds.to_i.freeze

      STAGES = {
        groups: Gitlab::BulkImport::Stage::ImportGroupsWorker,
        finish: Gitlab::BulkImport::Stage::FinishImportWorker
      }.freeze

      private

      def perform(bulk_import_id, waiters, next_stage)
        new_waiters = wait_for_jobs(waiters)

        if new_waiters.empty?
          next_stage_worker(next_stage).perform_async(project_id)
        else
          self.class.perform_in(INTERVAL, project_id, new_waiters, next_stage)
        end
      end

      def wait_for_jobs(waiters)
        waiters.each_with_object({}) do |(key, remaining), new_waiters|
          waiter = JobWaiter.new(remaining, key)

          # We wait for a brief moment of time so we don't reschedule if we can
          # complete the work fast enough.
          waiter.wait(BLOCKING_WAIT_TIME)

          next unless waiter.jobs_remaining > 0

          new_waiters[waiter.key] = waiter.jobs_remaining
        end
      end

      def next_stage_worker(next_stage)
        STAGES.fetch(next_stage.to_sym)
      end
    end
  end
end
