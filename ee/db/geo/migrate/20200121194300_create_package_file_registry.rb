# frozen_string_literal: true

class CreatePackageFileRegistry < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    create_table :package_file_registry, id: :serial, force: :cascade do |t|
      t.integer :package_file_id, null: false
      t.integer :state, default: 0, null: false
      t.integer :retry_count, default: 0
      t.string :last_sync_failure, limit: 255 # rubocop:disable Migration/PreventStrings
      t.datetime_with_timezone :retry_at
      t.datetime_with_timezone :last_synced_at
      t.datetime_with_timezone :created_at, null: false

      t.index :package_file_id, name: :index_package_file_registry_on_repository_id, using: :btree
      t.index :retry_at, name: :index_package_file_registry_on_retry_at, using: :btree
      t.index :state, name: :index_package_file_registry_on_state, using: :btree
    end
  end
end
