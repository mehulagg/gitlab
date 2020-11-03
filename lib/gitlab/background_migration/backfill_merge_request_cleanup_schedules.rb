# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Consists of model used for migration and other common logic.
    class BackfillMergeRequestCleanupSchedules
      # Model used for migration.
      class MergeRequest < ActiveRecord::Base
        include EachBatch

        self.table_name = 'merge_requests'

        def self.closed
          eligible(2)
        end

        def self.merged
          eligible(3)
        end

        def self.eligible(state_id)
          where(%{
            merge_requests.state_id = '#{state_id}'
            AND NOT EXISTS (
              SELECT 1
              FROM merge_request_cleanup_schedules cleanup_schedules
              WHERE cleanup_schedules.merge_request_id = merge_requests.id
            )
          })
        end
      end

      def backfill(merge_requests)
        ActiveRecord::Base.connection.execute <<~SQL
          INSERT INTO merge_request_cleanup_schedules (merge_request_id, scheduled_at, created_at, updated_at)
          #{merge_requests.to_sql}
          ON CONFLICT (merge_request_id) DO NOTHING;
        SQL
      end
    end
  end
end
