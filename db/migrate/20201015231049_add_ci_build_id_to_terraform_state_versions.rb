# frozen_string_literal: true

class AddCiBuildIdToTerraformStateVersions < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless column_exists?(:terraform_state_versions, :ci_build_id)
      add_column :terraform_state_versions, :ci_build_id, :bigint
    end

    add_concurrent_index :terraform_state_versions, :ci_build_id
    add_concurrent_foreign_key :terraform_state_versions, :ci_builds, column: :ci_build_id, on_delete: :nullify
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists :terraform_state_versions, :ci_builds, column: :ci_build_id
    end

    remove_concurrent_index :terraform_state_versions, :ci_build_id
    remove_column :terraform_state_versions, :ci_build_id
  end
end
