# frozen_string_literal: true

class CreateBulkImportTrackers < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :bulk_import_trackers, if_not_exists: true do |t|
      t.bigint :entity_id, index: true, null: false

      t.text :relation, null: false
      t.text :next_page
      t.boolean :has_next_page, default: false, null: false

      t.index %w(entity_id relation), unique: true
    end

    add_text_limit :bulk_import_trackers, :relation, 255
    add_text_limit :bulk_import_trackers, :next_page, 255
  end

  def down
    drop_table :bulk_import_trackers
  end
end
