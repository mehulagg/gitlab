# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddVerificationIndexesToLfsObjects < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  VERIFICATION_STATE_INDEX_NAME = "index_lfs_objects_on_verification_state"
  PENDING_VERIFICATION_INDEX_NAME = "index_lfs_objects_pending_verification"
  FAILED_VERIFICATION_INDEX_NAME = "index_lfs_objects_failed_verification"
  NEEDS_VERIFICATION_INDEX_NAME = "index_lfs_objects_needs_verification"

  disable_ddl_transaction!

  def up
    add_concurrent_index :lfs_objects, :verification_state, name: VERIFICATION_STATE_INDEX_NAME
    add_concurrent_index :lfs_objects, :verified_at, where: "(verification_state = 0)", order: { verified_at: 'ASC NULLS FIRST' }, name: PENDING_VERIFICATION_INDEX_NAME
    add_concurrent_index :lfs_objects, :verification_retry_at, where: "(verification_state = 3)", order: { verification_retry_at: 'ASC NULLS FIRST' }, name: FAILED_VERIFICATION_INDEX_NAME
    add_concurrent_index :lfs_objects, :verification_state, where: "(verification_state = 0 OR verification_state = 3)", name: NEEDS_VERIFICATION_INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :lfs_objects, VERIFICATION_STATE_INDEX_NAME
    remove_concurrent_index_by_name :lfs_objects, PENDING_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name :lfs_objects, FAILED_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name :lfs_objects, NEEDS_VERIFICATION_INDEX_NAME
  end
end
