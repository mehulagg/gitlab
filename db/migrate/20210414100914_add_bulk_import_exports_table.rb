# frozen_string_literal: true

class AddBulkImportExportsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    create_table :bulk_import_exports do |t|
      t.bigint :group_id
      t.bigint :project_id
      t.timestamps_with_timezone null: false
      t.integer :status, limit: 2, null: false, default: 0
      t.text :relation, null: false
      t.text :jid, unique: true
      t.text :error
    end

    add_text_limit :bulk_import_exports, :relation, 255
    add_text_limit :bulk_import_exports, :jid, 255
    add_text_limit :bulk_import_exports, :error, 255
  end

  def down
    drop_table :bulk_import_exports
  end
end
