# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedMigrationWrapper
        def perform(batch_tracking_record)
          return if batch_tracking_record.migration_aborted?

          begin
            start_tracking_execution(batch_tracking_record)

            execute_batch(batch_tracking_record)

            batch_tracking_record.status = :succeeded
          rescue => e
            batch_tracking_record.status = :failed

            raise e
          ensure
            finish_tracking_execution(batch_tracking_record)
          end
        end

        private

        def start_tracking_execution(tracking_record)
          tracking_record.update!(attempt: tracking_record.attempt + 1, status: :running, started_at: Time.current)
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
        end

        def finish_tracking_execution(tracking_record)
          tracking_record.finished_at = Time.current
          tracking_record.save!
        end
      end
    end
  end
end
