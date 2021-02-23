# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class MigrationService
        def load_migration_crons
          batched_migrations = BatchedMigration.active.all

          bulk_add_cron_jobs(batched_migrations)
        end

        def create_active_migration!(
          job_class_name,
          table_name,
          column_name,
          interval,
          min_value,
          max_value,
          batch_class_name,
          batch_size,
          sub_batch_size,
          job_arguments
        )

          batched_migration = BatchedMigration.create!(
            job_class_name: job_class_name,
            table_name: table_name,
            column_name: column_name,
            interval: interval,
            min_value: min_value,
            max_value: max_value,
            batch_class_name: batch_class_name,
            batch_size: batch_size,
            sub_batch_size: sub_batch_size,
            job_arguments: job_arguments,
            status: :active)

          bulk_add_cron_jobs([batched_migration])
        end

        def finish_migration_execution(batched_migration)
          batched_migration.finished!

          remove_cron_job(batched_migration)
        end

        def abort_migration_executions(job_class_name, table_name, column_name)
          BatchedMigration.for_batch_configuration(job_class_name, table_name, column_name).each do |batched_migration|
            next if batched_migration.finished? || batched_migration.aborted

            batched_migration.aborted!

            remove_cron_job(batched_migration)
          end
        end

        private

        def remove_cron_job(batched_migration)
          cron_job_name = cron_job_name_for_migration(batched_migration)

          Sidekiq::Cron::Job.destroy(cron_job_name)
        end

        def bulk_add_cron_jobs(migrations)
          cron_job_configurations = migrations.each_with_object({}) do |migration, configurations|
            cron_job_name = cron_job_name_for_migration(migration)

            configurations[cron_job_name] = {
              'class' => 'Gitlab::Database::BackgroundMigration::Scheduler',
              'cron' => "*/#{migration.interval / 60} * * * *",
              'args' => [migration.id]
            }
          end

          Sidekiq::Cron::Job.load_from_hash(cron_job_configurations)
        end

        def cron_job_name_for_migration(migration)
          "#{active_migration.job_class_name}_#{active_migration.id}"
        end
      end
    end
  end
end
