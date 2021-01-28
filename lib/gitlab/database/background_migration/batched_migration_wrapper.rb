# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedMigrationWrapper
        def perform(id_for_batch)
          batch_tracking_record = BatchedJob.includes(:migration).find(id_for_batch)

          begin
            job_instance = batch_tracking_record.job_class.new

            batch_tracking_record.update!(attempt: batch_tracking_record.attempt + 1, status: :running)

            job_instance.perform(batch_tracking_record.min_value, batch_tracking_record.max_value,
                batch_tracking_record.migration.table_name, batch_tracking_record.migration.column_name,
                batch_tracking_record.sub_batch_size, *batch_tracking_record.arguments)

            batch_tracking_record.status = :succeeded
          rescue => e
            batch_tracking_record.status = :failed

            raise e
          ensure
            batch_tracking_record.save!
          end
        end
      end
    end
  end
end
