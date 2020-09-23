# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddDesignRegistry < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  # rubocop:disable Migration/Datetime
  # rubocop:disable Migration/PreventStrings
  def change
    create_table :design_registry, id: :serial, force: :cascade do |t|
      t.integer :project_id, null: false
      t.string :state, limit: 20
      t.integer :retry_count, default: 0
      t.string :last_sync_failure
      t.boolean :force_to_redownload
      t.boolean :missing_on_primary
      t.datetime :retry_at
      t.datetime :last_synced_at
      t.datetime :created_at, null: false

      t.index :project_id, name: :index_design_registry_on_project_id, using: :btree
      t.index :retry_at, name: :index_design_registry_on_retry_at, using: :btree
      t.index :state, name: :index_design_registry_on_state, using: :btree
    end
  end
  # rubocop:enable Migration/PreventStrings
  # rubocop:enable Migration/Datetime
end
