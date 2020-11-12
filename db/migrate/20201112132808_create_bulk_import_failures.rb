# frozen_string_literal: true

class CreateBulkImportFailures < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    create_table :bulk_import_failures do |t|
      t.references :bulk_import_entity, null: false, index: true
      t.datetime_with_timezone :created_at, null: false
      t.text :relation_key
      t.text :exception_class
      t.text :exception_message
      t.text :correlation_id_value, index: true
    end

    add_text_limit :bulk_import_failures, :relation_key, 64
    add_text_limit :bulk_import_failures, :exception_class, 128
    add_text_limit :bulk_import_failures, :exception_message, 255
    add_text_limit :bulk_import_failures, :correlation_id_value, 128
  end
end
