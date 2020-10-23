# frozen_string_literal: true

class CreateMergeRequestCleanupSchedules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :merge_request_cleanup_schedules, if_not_exists: true do |t|
      t.references :merge_request, index: true, foreign_key: { to_table: :merge_requests, on_delete: :cascade }, null: false
      t.datetime_with_timezone :scheduled_at, null: false
      t.datetime_with_timezone :completed_at, null: true

      t.timestamps_with_timezone

      t.index [:scheduled_at, :completed_at], name: 'index_mr_cleanup_schedules_timestamps'
    end
  end
end
