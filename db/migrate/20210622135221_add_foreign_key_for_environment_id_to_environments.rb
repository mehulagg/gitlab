# frozen_string_literal: true

class AddForeignKeyForEnvironmentIdToEnvironments < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :deployments, :environments, column: :environment_id, on_delete: :cascade
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists :deployments, :environments
    end
  end
end
