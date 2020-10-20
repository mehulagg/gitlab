# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module DuplicateJobs
      module Strategies
        # This strategy takes a lock before scheduling the job in a queue and
        # removes the lock before the job starts allowing a new job to be queued
        # while a job is still executing.
        class Base
          def initialize(duplicate_job)
            @duplicate_job = duplicate_job
          end

          def schedule(job)
            if deduplicatable_job? && check! && duplicate_job.duplicate?
              job['duplicate-of'] = duplicate_job.existing_jid

              if duplicate_job.droppable?
                Gitlab::SidekiqLogging::DeduplicationLogger.instance.log(
                  job, "dropped #{strategy_name}", duplicate_job.options)
                return false
              end
            end

            yield
          end

          def perform(_job)
            raise NotImplementedError
          end

          private

          attr_reader :duplicate_job

          def strategy_name
            self.class.name.to_s.demodulize
              .underscore.humanize.downcase
          end

          def deduplicatable_job?
            !duplicate_job.scheduled? || duplicate_job.options[:including_scheduled]
          end

          def check!
            duplicate_job.check!(expiry)
          end

          def expiry
            return DuplicateJob::DUPLICATE_KEY_TTL unless duplicate_job.scheduled?

            time_diff = duplicate_job.scheduled_at.to_i - Time.now.to_i

            time_diff > 0 ? time_diff : DuplicateJob::DUPLICATE_KEY_TTL
          end
        end
      end
    end
  end
end
