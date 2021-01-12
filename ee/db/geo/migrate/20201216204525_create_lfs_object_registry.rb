# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateLfsObjectRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :lfs_object_registry, id: :bigserial, force: :cascade do |t|
      t.integer :lfs_object_id, null: false
      t.integer :state, default: 0, null: false, limit: 2
      t.integer :retry_count, default: 0, limit: 2
      t.datetime_with_timezone :retry_at
      t.datetime_with_timezone :last_synced_at
      t.datetime_with_timezone :created_at, null: false
      t.text :last_sync_failure

      t.index :lfs_object_id, name: :index_lfs_object_registry_on_lfs_object_id
      t.index :retry_at
      t.index :state
    end

    add_text_limit :lfs_object_registry, :last_sync_failure, 255
  end

  def down
    drop_table :lfs_object_registry
  end
end
