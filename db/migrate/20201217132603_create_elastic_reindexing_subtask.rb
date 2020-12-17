class CreateElasticReindexingSubtask < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class ReindexingTask < ActiveRecord::Base
    self.table_name = 'elastic_reindexing_tasks'
  end

  class ReindexingSubtask < ActiveRecord::Base
    self.table_name = 'elastic_reindexing_subtasks'
  end

  def up
    create_table :elastic_reindexing_subtasks do |t|
      t.references :elastic_reindexing_task, foreign_key: { on_delete: :cascade }, null: false
      t.integer :documents_count
      t.text :index_name_from
      t.text :index_name_to
      t.text :elastic_task
    end

    add_text_limit :elastic_reindexing_subtasks, :index_name_from, 255
    add_text_limit :elastic_reindexing_subtasks, :index_name_to, 255
    add_text_limit :elastic_reindexing_subtasks, :elastic_task, 255

    ReindexingTask.find_each do |task|
      next if task.index_name_from.blank?

      ReindexingSubtask.create(
        elastic_reindexing_task_id: task.id,
        documents_count: task.documents_count,
        index_name_from: task.index_name_from,
        index_name_to: task.index_name_to,
        elastic_task: task.elastic_task
      )
    end
  end

  def down
    drop_table :elastic_reindexing_subtasks
  end
end
