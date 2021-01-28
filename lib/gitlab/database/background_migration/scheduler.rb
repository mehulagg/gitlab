# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class Scheduler
        include Gitlab::Database::Migrations::BackgroundMigrationHelpers

        BATCHED_MIGRATION_CLASS_NAME = "::#{module_parent_name}::BatchedMigrationWrapper"

        def perform
          BatchedMigration.active.each do |active_migration|
            last_created_job = active_migration.last_created_job

            next if last_created_job && last_created_job.created_at > (Time.current - active_migration.interval)

            next_batched_job = create_next_batched_job!(active_migration, last_created_job)

            if next_batched_job.nil?
              finish_active_migration(active_migration)
              next
            end

            migrate_async(BATCHED_MIGRATION_CLASS_NAME, next_batched_job.id)
          end
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
          active_migration.finished!
        end
      end
    end
  end
end
