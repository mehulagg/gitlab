# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Backfill draft column on open merge requests based on regex parsing of
    #   their titles.
    #
    class BackfillDraftStatusOnMergeRequests
      # Migration only version of MergeRequest table
      class MergeRequest < ActiveRecord::Base
        self.table_name = 'merge_requests'

        def self.eligible
          where(state_id: 1)
            .where(draft: false)
            .where("title ~* ?", '^\\[draft\\]|\\(draft\\)|draft:|draft|\\[WIP\\]|WIP:|WIP')
        end
      end

      def perform(start_id, end_id)
        eligible_mrs = MergeRequest.eligible.where(id: start_id..end_id).pluck(:id)

        unless eligible_mrs.empty?
          MergeRequest.where(id: eligible_mrs).update_all(draft: true)
        end
      end
    end
  end
end
