# frozen_string_literal: true

class AddElasticSliceAndRetryAttemptToElasticReindexingSubtasks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :elastic_reindexing_subtasks, :elastic_max_slice, :integer, null: false, default: 0
    add_column :elastic_reindexing_subtasks, :elastic_slice, :integer, null: false, default: 0
    add_column :elastic_reindexing_subtasks, :retry_attempt, :integer, null: false, default: 0
  end
end
