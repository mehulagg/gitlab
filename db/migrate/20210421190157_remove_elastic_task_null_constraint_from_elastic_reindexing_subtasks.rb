# frozen_string_literal: true

class RemoveElasticTaskNullConstraintFromElasticReindexingSubtasks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    remove_not_null_constraint :elastic_reindexing_subtasks, :elastic_task
    change_column_null(:elastic_reindexing_subtasks, :elastic_task, true)
  end

  def down
    change_column_null(:elastic_reindexing_subtasks, :elastic_task, false)
    add_not_null_constraint :elastic_reindexing_subtasks, :elastic_task
  end
end
