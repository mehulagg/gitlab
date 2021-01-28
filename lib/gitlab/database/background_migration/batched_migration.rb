# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedMigration < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
        self.table_name = :batched_background_migrations

        has_many :batched_jobs, foreign_key: :batched_background_migration_id

        enum status: {
          paused: 0,
          active: 1,
          aborted: 2,
          finished: 3
        }

        def last_created_job
          batched_jobs.order(created_at: :desc).first
        end

        def job_name
          job_class_name.constantize
        end
      end
    end
  end
end
