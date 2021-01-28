# frozen_string_literal: true

module Gitlab
  module Database
    module BackgroundMigration
      class BatchedJob < ActiveRecord::Base # rubocop:disable Rails/ApplicationRecord
        self.table_name = :batched_background_migration_jobs

        belongs_to :batched_migration, foreign_key: :batched_background_migration_id

        scope :finished, ->() { where(status: [:failed, :succeeded]) }

        enum status: {
          pending: 0,
          running: 1,
          failed: 2,
          succeeded: 3
        }
      end

      def migration_class
        migration&.migration_class
      end
    end
  end
end
