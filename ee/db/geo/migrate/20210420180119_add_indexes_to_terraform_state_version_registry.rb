# frozen_string_literal: true

class AddIndexesToTerraformStateVersionRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  TERRAFORM_STATE_VERSION_ID_INDEX_NAME = "index_terraform_state_version_registry_on_t_state_version_id"
  FAILED_VERIFICATION_INDEX_NAME = "terraform_state_version_registry_failed_verification"
  NEEDS_VERIFICATION_INDEX_NAME = "terraform_state_version_registry_needs_verification"
  PENDING_VERIFICATION_INDEX_NAME = "terraform_state_version_registry_pending_verification"

  REGISTRY_TABLE = :terraform_state_version_registry

  disable_ddl_transaction!

  def up
    add_concurrent_index REGISTRY_TABLE, :terraform_state_version_id, name: TERRAFORM_STATE_VERSION_ID_INDEX_NAME, unique: true
    add_concurrent_index REGISTRY_TABLE, :retry_at
    add_concurrent_index REGISTRY_TABLE, :state
    add_concurrent_index REGISTRY_TABLE, :verification_retry_at, name: FAILED_VERIFICATION_INDEX_NAME, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 3))"
    add_concurrent_index REGISTRY_TABLE, :verification_state, name: NEEDS_VERIFICATION_INDEX_NAME, where: "((state = 2)  AND (verification_state = ANY (ARRAY[0, 3])))"
    add_concurrent_index REGISTRY_TABLE, :verified_at, name: PENDING_VERIFICATION_INDEX_NAME, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 0))"
  end

  def down
    remove_concurrent_index_by_name REGISTRY_TABLE, name: TERRAFORM_STATE_VERSION_ID_INDEX_NAME
    remove_concurrent_index_by_name REGISTRY_TABLE, name: :index_terraform_state_version_registry_on_retry_at
    remove_concurrent_index_by_name REGISTRY_TABLE, name: :index_terraform_state_version_registry_on_state
    remove_concurrent_index_by_name REGISTRY_TABLE, name: FAILED_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name REGISTRY_TABLE, name: NEEDS_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name REGISTRY_TABLE, name: PENDING_VERIFICATION_INDEX_NAME
  end
end
