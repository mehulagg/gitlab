# frozen_string_literal: true

class AddBulkImportForeignKeyToImportEntities < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = 'index_import_entities_on_bulk_import_id'.freeze

  def up
    with_lock_retries do
      add_foreign_key :import_entities, :bulk_imports, column: :bulk_import_id, on_delete: :cascade # rubocop:disable Migration/AddConcurrentForeignKey
    end

    add_concurrent_index :import_entities, :bulk_import_id, name: INDEX_NAME
  end

  def down
    with_lock_retries do
      remove_foreign_key :import_entities, column: :bulk_import_id
    end

    remove_concurrent_index_by_name :import_entities, INDEX_NAME
  end
end
