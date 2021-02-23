# frozen_string_literal: true

class CreateBulkImportEntityPipelines < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      unless table_exists?(:bulk_import_entity_pipeline_statuses)
        create_table :bulk_import_entity_pipeline_statuses do |t|
          t.references :bulk_import_entity,
            index: false,
            null: false,
            foreign_key: { on_delete: :cascade }

          t.text :stage_name
          t.text :pipeline_name

          t.integer :status, null: false, limit: 2
          t.text :jid

          t.timestamps_with_timezone
        end
      end
    end

    add_text_limit(:bulk_import_entity_pipeline_statuses, :stage_name, 255)
    add_text_limit(:bulk_import_entity_pipeline_statuses, :pipeline_name, 255)
    add_text_limit(:bulk_import_entity_pipeline_statuses, :jid, 255)
  end

  def down
    with_lock_retries do
      drop_table :bulk_import_entity_pipeline_statuses
    end
  end
end
