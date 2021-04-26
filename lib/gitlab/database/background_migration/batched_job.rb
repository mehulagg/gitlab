# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedJob < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
        self.table_name = :batched_background_migration_jobs

        MAX_RETRIES = 3
        STUCK_JOBS_TIMEOUT = 1.hour.freeze

        belongs_to :batched_migration, foreign_key: :batched_background_migration_id

        scope :active, -> { where(status: [:pending, :running]) }
        scope :stuck, -> { active.where('updated_at < ?', Time.current - STUCK_JOBS_TIMEOUT) }
        scope :retriable, -> { where(status: :failed).where('attempts < ?', MAX_RETRIES).or(self.stuck) }

        enum status: {
          pending: 0,
          running: 1,
          failed: 2,
          succeeded: 3
        }

        delegate :aborted?, :job_class, :table_name, :column_name, :job_arguments,
          to: :batched_migration, prefix: :migration
      end
    end
  end
end
