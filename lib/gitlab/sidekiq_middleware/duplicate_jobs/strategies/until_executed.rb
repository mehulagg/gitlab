# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module DuplicateJobs
      module Strategies
        # This strategy takes a lock before scheduling the job in a queue and
        # removes the lock after the job has executed preventing a new job to be queued
        # while a job is still executing.
        class UntilExecuted < Base
          include DeduplicatesWhenScheduling

          def perform(job)
            job.merge!(duplicate_job.wal_location) if duplicate_job.utilizes_load_balancing_capabilities?

            yield

            duplicate_job.delete!
          end
        end
      end
    end
  end
end
