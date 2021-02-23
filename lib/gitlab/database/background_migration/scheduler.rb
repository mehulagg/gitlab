# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class Scheduler
        def perform(batched_migration_id)
          batched_migration = BatchedMigration.find(batched_migration_id)

          return unless batched_migration.active?

          last_created_job = batched_migration.last_created_job

          next_batched_job = create_next_batched_job!(batched_migration, last_created_job)

          if next_batched_job.nil?
            finish_active_migration(batched_migration)
            next
          end

          # BackgroundMigrationWorker checks database replication lag and gets an ExclusiveLease based on
          # the job class_name, which we avoid by calling the wrapper directly. We don't need the lease
          # because sidekiq-cron already prevents multiple instances of the same job.
          BatchedMigrationWrapper.new.perform(next_batched_job)
        end

        private

        def create_next_batched_job!(active_migration, last_created_job)
          next_batch_range = find_next_batch_range(active_migration, last_created_job)

          return if next_batch_range.nil?

          active_migration.create_batched_job!(next_batch_range.min, next_batch_range.max)
        end

        def find_next_batch_range(active_migration, last_created_job)
          batching_strategy = active_migration.batch_class_name.constantize.new
          previous_max_value = last_created_job&.max_value&.next || active_migration.min_value

          next_batch_bounds = batching_strategy.next_batch(
            active_migration.table_name,
            active_migration.column_name,
            batch_size: active_migration.batch_size,
            previous_max_value: previous_max_value)

          return if next_batch_bounds.nil?

          clamped_batch_range(active_migration, next_batch_bounds)
        end

        def clamped_batch_range(active_migration, next_bounds)
          min_value, max_value = next_bounds

          return if min_value > active_migration.max_value

          max_value = max_value.clamp(min_value, active_migration.max_value)

          (min_value..max_value)
        end

        def finish_active_migration(active_migration)
          MigrationService.new.finish_migration_execution(active_migration)
        end
      end
    end
  end
end
