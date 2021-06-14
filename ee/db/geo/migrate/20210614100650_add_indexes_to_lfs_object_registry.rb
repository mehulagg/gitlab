# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddIndexesToLfsObjectRegistry < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  LFS_OBJECT_ID_INDEX_NAME = "index_lfs_object_registry_on_lfs_object_id"
  FAILED_VERIFICATION_INDEX_NAME = "lfs_object_registry_failed_verification"
  NEEDS_VERIFICATION_INDEX_NAME = "lfs_object_registry_needs_verification"
  PENDING_VERIFICATION_INDEX_NAME = "lfs_object_registry_pending_verification"

  REGISTRY_TABLE = :lfs_object_registry

  disable_ddl_transaction!

  def up
    add_concurrent_index REGISTRY_TABLE, :lfs_object_id, name: LFS_OBJECT_ID_INDEX_NAME, unique: true
    add_concurrent_index REGISTRY_TABLE, :retry_at
    add_concurrent_index REGISTRY_TABLE, :state
    add_concurrent_index REGISTRY_TABLE, :verification_retry_at, name: FAILED_VERIFICATION_INDEX_NAME, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 3))"
    add_concurrent_index REGISTRY_TABLE, :verification_state, name: NEEDS_VERIFICATION_INDEX_NAME, where: "((state = 2)  AND (verification_state = ANY (ARRAY[0, 3])))"
    add_concurrent_index REGISTRY_TABLE, :verified_at, name: PENDING_VERIFICATION_INDEX_NAME, order: "NULLS FIRST", where: "((state = 2) AND (verification_state = 0))"
  end

  def down
    remove_concurrent_index_by_name REGISTRY_TABLE, name: LFS_OBJECT_ID_INDEX_NAME
    remove_concurrent_index_by_name REGISTRY_TABLE, name: :index_lfs_object_registry_on_retry_at
    remove_concurrent_index_by_name REGISTRY_TABLE, name: :index_lfs_object_registry_on_state
    remove_concurrent_index_by_name REGISTRY_TABLE, name: FAILED_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name REGISTRY_TABLE, name: NEEDS_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name REGISTRY_TABLE, name: PENDING_VERIFICATION_INDEX_NAME
  end
end
