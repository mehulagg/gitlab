# frozen_string_literal: true

class AddSortedToMergeRequestDiffs < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :merge_request_diffs, :sorted, :boolean, null: false, default: false
  end
end
