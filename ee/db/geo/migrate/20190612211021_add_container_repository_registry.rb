# frozen_string_literal: true

class AddContainerRepositoryRegistry < ActiveRecord::Migration[5.0]
  DOWNTIME = false

  # rubocop:disable Migration/Datetime
  # rubocop:disable Migration/PreventStrings
  def change
    create_table :container_repository_registry, id: :serial, force: :cascade do |t|
      t.integer :container_repository_id, null: false
      t.string :state
      t.integer :retry_count, default: 0
      t.string :last_sync_failure
      t.datetime :retry_at
      t.datetime :last_synced_at
      t.datetime :created_at, null: false

      t.index :container_repository_id, name: :index_container_repository_registry_on_repository_id, using: :btree
      t.index :retry_at, name: :index_container_repository_registry_on_retry_at, using: :btree
      t.index :state, name: :index_container_repository_registry_on_state, using: :btree
    end
  end
  # rubocop:enable Migration/PreventStrings
  # rubocop:enable Migration/Datetime
end
