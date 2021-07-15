# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module DuplicateJobs
      module Strategies
        # This strategy takes a lock before scheduling the job in a queue and
        # removes the lock before the job starts allowing a new job to be queued
        # while a job is still executing.
        class UntilExecuting < Base
          include DeduplicatesWhenScheduling

          def perform(job)
            job.merge!(duplicate_job.wal_location) if duplicate_job.utilizes_load_balancing_capabilities?
            duplicate_job.delete!

            yield
          end
        end
      end
    end
  end
end
