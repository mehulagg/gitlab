# frozen_string_literal: true

class AddBulkImportExportUploadsTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    create_table :bulk_import_export_uploads do |t|
      t.bigint :export_id, null: false
      t.datetime_with_timezone :updated_at, null: false
      t.text :export_file
    end

    add_text_limit :bulk_import_export_uploads, :export_file, 255
  end

  def down
    drop_table :bulk_import_export_uploads
  end
end
