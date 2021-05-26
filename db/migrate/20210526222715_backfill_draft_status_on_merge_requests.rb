# frozen_string_literal: true

class BackfillDraftStatusOnMergeRequests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    update_column_in_batches(:merge_requests, :draft, true) do |table, query|
      query.where(table[:state_id].eq(1)).where(table[:title].matches_regexp('^\\[draft\\]|\\(draft\\)|draft:|draft|\\[WIP\\]|WIP:|WIP', false))
    end
  end

  def down
    # noop
  end
end
