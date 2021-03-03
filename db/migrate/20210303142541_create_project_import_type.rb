# frozen_string_literal: true

class CreateProjectImportType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :project_import_types do |t|
        t.references :project, foreign_key: { on_delete: :cascade }, null: false, index: { unique: true }
        t.timestamps_with_timezone null: false
        t.text :name, null: false
      end
    end

    add_concurrent_index :project_import_types, [:project_id, :created_at]
    add_text_limit :project_import_types, :name, 255
  end

  def down
    with_lock_retries do
      drop_table :project_import_types
    end
  end
end
