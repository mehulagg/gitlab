# frozen_string_literal: true
#
class CreatePinnedProjectsTable < ActiveRecord::Migration[5.1]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  INDEX_NAME = 'index_pinned_projects_on_user_id_and_project_id'

  def up
    create_table :pinned_projects do |t|
      t.references :user, foreign_key: { on_delete: :cascade }, index: true, null: false
      t.references :project, foreign_key: { on_delete: :cascade }, null: false
    end

    add_index :pinned_projects, [:user_id, :project_id], unique: true, name: INDEX_NAME
  end

  def down
    drop_table :pinned_projects
  end
end
