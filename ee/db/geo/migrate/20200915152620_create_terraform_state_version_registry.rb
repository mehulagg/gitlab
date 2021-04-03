# frozen_string_literal: true

class CreateTerraformStateVersionRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:terraform_state_version_registry)
      ActiveRecord::Base.transaction do
        create_table :terraform_state_version_registry, id: :bigserial, force: :cascade do |t|
          t.bigint :terraform_state_version_id, null: false
          t.integer :state, default: 0, null: false, limit: 2
          t.integer :retry_count, default: 0, null: false, limit: 2
          t.datetime_with_timezone :retry_at
          t.datetime_with_timezone :last_synced_at
          t.datetime_with_timezone :created_at, null: false
          t.text :last_sync_failure

          t.index :terraform_state_version_id, name: :index_tf_state_versions_registry_on_tf_state_versions_id
          t.index :retry_at
          t.index :state
        end
      end
    end

    add_text_limit :terraform_state_version_registry, :last_sync_failure, 255
  end

  def down
    drop_table :terraform_state_version_registry
  end
end
