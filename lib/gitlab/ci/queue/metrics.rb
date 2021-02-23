# frozen_string_literal: true

module Gitlab
  module Ci
    module Queue
      class Metrics
        extend Gitlab::Utils::StrongMemoize

        QUEUE_OPERATION_BUCKETS = [1, 5, 10, 50, 100, 500, 1000, 2000, 5000].freeze
        QUEUE_DURATION_SECONDS_BUCKETS = [1, 3, 10, 30, 60, 300, 900, 1800, 3600].freeze

        METRICS_SHARD_TAG_PREFIX = 'metrics_shard::'
        DEFAULT_METRICS_SHARD = 'default'

        attr_reader :runner

        def initialize(runner)
          @runner = runner
        end

        def register_failure
          self.class.failed_attempt_counter.increment
          self.class.attempt_counter.increment
        end

        def register_success(job)
          labels = { shared_runner: runner.instance_type?,
                     jobs_running_for_project: jobs_running_for_project(job),
                     shard: DEFAULT_METRICS_SHARD }

          if runner.instance_type?
            shard = runner.tag_list.sort.find { |name| name.starts_with?(METRICS_SHARD_TAG_PREFIX) }
            labels[:shard] = shard.gsub(METRICS_SHARD_TAG_PREFIX, '') if shard
          end

          self.class.job_queue_duration_seconds.observe(labels, Time.current - job.queued_at) unless job.queued_at.nil?
          self.class.attempt_counter.increment
        end

        def self.failed_attempt_counter
          strong_memoize(:failed_attempt_counter) do
            name = :job_register_attempts_failed_total
            comment = 'Counts the times a runner tries to register a job'

            Gitlab::Metrics.counter(name, comment)
          end
        end

        def self.attempt_counter
          strong_memoize(:attempt_counter) do
            name = :job_register_attempts_total
            comment = 'Counts the times a runner tries to register a job'

            Gitlab::Metrics.counter(name, comment)
          end
        end

        def self.job_queue_duration_seconds
          strong_memoize(:job_queue_duration_seconds) do
            name = :job_queue_duration_seconds
            comment = 'Request handling execution time'
            labels = {}
            buckets = JOB_QUEUE_DURATION_SECONDS_BUCKETS

            Gitlab::Metrics.histogram(name, comment, labels, buckets)
          end
        end
      end
    end
  end
end
