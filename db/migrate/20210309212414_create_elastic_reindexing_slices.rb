# frozen_string_literal: true

class CreateElasticReindexingSlices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class ReindexingSubtask < ActiveRecord::Base
    self.table_name = 'elastic_reindexing_subtasks'
  end

  class ReindexingSlice < ActiveRecord::Base
    self.table_name = 'elastic_reindexing_slices'
  end

  def up
    with_lock_retries do
      add_column :elastic_reindexing_subtasks, :elastic_max_slice, :integer
      change_column_null(:elastic_reindexing_subtasks, :elastic_task, true)
    end

    remove_not_null_constraint(:elastic_reindexing_subtasks, :elastic_task)

    unless table_exists?(:elastic_reindexing_slices)
      with_lock_retries do
        create_table :elastic_reindexing_slices do |t|
          t.references :elastic_reindexing_subtask, foreign_key: { on_delete: :cascade }, null: false, index: { name: 'idx_elastic_reindexing_slices_on_elastic_reindexing_subtask_id' }
          t.text :elastic_task, null: false
          t.integer :elastic_slice
          t.integer :retry_attempt, null: false, default: 0
          t.timestamps_with_timezone null: false
        end
      end
    end

    add_text_limit :elastic_reindexing_slices, :elastic_task, 255

    ReindexingSubtask.find_each do |subtask|
      next if ReindexingSlice.where(elastic_reindexing_subtask_id: subtask.id).exists?

      ReindexingSlice.create(
        elastic_reindexing_subtask_id: subtask.id,
        elastic_task: subtask.elastic_task,
        retry_attempt: 0
      )
    end
  end

  def down
    with_lock_retries do
      remove_column :elastic_reindexing_subtasks, :elastic_max_slice
      change_column_null(:elastic_reindexing_subtasks, :elastic_task, false)
    end

    add_not_null_constraint(:elastic_reindexing_subtasks, :elastic_task)

    with_lock_retries do
      drop_table :elastic_reindexing_slices
    end
  end
end
