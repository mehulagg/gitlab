# frozen_string_literal: true

class CreateProjectVaultSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_table_with_constraints :vault_settings do |t|
      t.belongs_to :project, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.timestamps null: false
      t.text :server_url, null: false
      t.text :auth_role
      t.text :auth_path

      t.text_limit :server_url, 2047
      t.text_limit :auth_role, 255
      t.text_limit :auth_path, 255
    end
  end

  def down
    with_lock_retries do
      drop_table :vault_settings
    end
  end
end
