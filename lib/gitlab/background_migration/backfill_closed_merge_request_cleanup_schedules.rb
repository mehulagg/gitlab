# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Backfill merge request cleanup schedules of closed merge requests without
    # any corresponding merge request cleanup schedules yet.
    class BackfillClosedMergeRequestCleanupSchedules < BackfillMergeRequestCleanupSchedules
      def perform(start_id, end_id)
        eligible_mrs =
          MergeRequest
            .closed
            .select("merge_requests.id, metrics.latest_closed_at + interval '14 days', NOW(), NOW()")
            .joins('INNER JOIN merge_request_metrics metrics ON metrics.merge_request_id = merge_requests.id')
            .where(id: start_id..end_id)

        backfill(eligible_mrs)
      end
    end
  end
end
