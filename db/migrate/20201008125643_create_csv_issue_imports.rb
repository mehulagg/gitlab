class CreateCsvIssueImports < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :csv_issue_imports do |t|
      t.bigint :project_id, null: false
      t.bigint :user_id, null: false

      t.timestamps_with_timezone
    end

    add_index :csv_issue_imports, :project_id
    add_index :csv_issue_imports, :user_id
  end

  def down
    drop_table :csv_issue_imports
  end
end
