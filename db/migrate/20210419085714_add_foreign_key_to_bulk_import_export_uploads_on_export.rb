# frozen_string_literal: true

class AddForeignKeyToBulkImportExportUploadsOnExport < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  INDEX_NAME = 'index_bulk_import_export_uploads_on_export_id'

  def up
    add_concurrent_foreign_key :bulk_import_export_uploads, :bulk_import_exports, column: :export_id, on_delete: :cascade
    add_concurrent_index :bulk_import_export_uploads, :export_id, name: INDEX_NAME
  end

  def down
    with_lock_retries do
      remove_foreign_key :bulk_import_export_uploads, column: :export_id
    end

    remove_concurrent_index_by_name :bulk_import_export_uploads, INDEX_NAME
  end
end
