# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedMigrationWrapper
        extend Gitlab::Utils::StrongMemoize

        # Wraps the execution of a batched_background_migration.
        #
        # Updates the job's tracking records with the status of the migration
        # when starting and finishing execution, and optionally saves batch_metrics
        # the migration provides, if any are given.
        #
        # The job's batch_metrics are serialized to JSON for storage.
        def perform(batch_tracking_record)
          start_tracking_execution(batch_tracking_record)
          track_prometheus_metrics(batch_tracking_record)

          execute_batch(batch_tracking_record)

          batch_tracking_record.status = :succeeded
        rescue => e
          batch_tracking_record.status = :failed

          raise e
        ensure
          finish_tracking_execution(batch_tracking_record)
        end

        private

        def start_tracking_execution(tracking_record)
          tracking_record.update!(attempts: tracking_record.attempts + 1, status: :running, started_at: Time.current)
        end

        def execute_batch(tracking_record)
          job_instance = tracking_record.migration_job_class.new

          job_instance.perform(
            tracking_record.min_value,
            tracking_record.max_value,
            tracking_record.migration_table_name,
            tracking_record.migration_column_name,
            tracking_record.sub_batch_size,
            *tracking_record.migration_job_arguments)

          if job_instance.respond_to?(:batch_metrics)
            tracking_record.metrics = job_instance.batch_metrics
          end
        end

        def finish_tracking_execution(tracking_record)
          tracking_record.finished_at = Time.current
          tracking_record.save!
        end

        def track_prometheus_metrics(tracking_record)
          migration = tracking_record.batched_migration

          self.class.gauge_batch_size.set(migration.prometheus_labels, tracking_record.batch_size)
          self.class.gauge_sub_batch_size.set(migration.prometheus_labels, tracking_record.sub_batch_size)
        end

        def self.gauge_batch_size
          strong_memoize(:gauge_batch_size) do
            Gitlab::Metrics.gauge(
              :batched_migration_job_batch_size,
              'Batch size for a batched migration job'
            )
          end
        end

        def self.gauge_sub_batch_size
          strong_memoize(:gauge_sub_batch_size) do
            Gitlab::Metrics.gauge(
              :batched_migration_job_sub_batch_size,
              'Sub-batch size for a batched migration job'
            )
          end
        end
      end
    end
  end
end
