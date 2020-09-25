# frozen_string_literal: true

class CreateImportEntities < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:import_entities)
      create_table :import_entities do |t|
        t.bigint :bulk_import_id, index: true, null: false
        t.bigint :parent_id
        t.bigint :namespace_id
        t.bigint :project_id

        t.integer :type, null: false, limit: 2
        t.text :source_full_path, null: false

        t.text :destination_name, null: false
        t.text :destination_full_path, null: false

        t.timestamps_with_timezone
      end
    end

    add_text_limit(:import_entities, :source_full_path, 255)
    add_text_limit(:import_entities, :destination_name, 255)
    add_text_limit(:import_entities, :destination_full_path, 255)
  end

  def down
    drop_table :import_entities
  end
end
