# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedMigration < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
        self.table_name = :batched_background_migrations

        has_many :batched_jobs, foreign_key: :batched_background_migration_id

        scope :for_batch_configuration, -> (job_class_name, table_name, column_name) do
          where(job_class_name: remove_toplevel_prefix(job_class_name),
                table_name: table_name,
                column_name: column_name)
        end

        enum status: {
          paused: 0,
          active: 1,
          aborted: 2,
          finished: 3
        }

        def self.remove_toplevel_prefix(name)
          name&.sub(/\A::/, '')
        end

        def create_batched_job!(min, max)
          batched_jobs.create!(min_value: min, max_value: max, batch_size: batch_size, sub_batch_size: sub_batch_size)
        end

        def last_created_job
          batched_jobs.order(created_at: :desc).first
        end

        def job_class
          job_class_name.constantize
        end

        def job_class_name=(class_name)
          write_attribute(:job_class_name, self.class.remove_toplevel_prefix(class_name))
        end

        def batch_class_name=(class_name)
          write_attribute(:batch_class_name, self.class.remove_toplevel_prefix(class_name))
        end
      end
    end
  end
end
