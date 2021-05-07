# frozen_string_literal: true

class AddVerificationIndexesToSnippetRepositoryRegistry < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  PENDING_VERIFICATION_INDEX_NAME = "snippet_repository_registry_pending_verification"
  FAILED_VERIFICATION_INDEX_NAME = "snippet_repository_registry_failed_verification"
  NEEDS_VERIFICATION_INDEX_NAME = "snippet_repository_registry_needs_verification"

  disable_ddl_transaction!

  def up
    add_concurrent_index :snippet_repository_registry, :verified_at, where: "(state = 2 AND verification_state = 0)", order: { verified_at: 'ASC NULLS FIRST' }, name: PENDING_VERIFICATION_INDEX_NAME
    add_concurrent_index :snippet_repository_registry, :verification_retry_at, where: "(state = 2 AND verification_state = 3)", order: { verification_retry_at: 'ASC NULLS FIRST' }, name: FAILED_VERIFICATION_INDEX_NAME
    add_concurrent_index :snippet_repository_registry, :verification_state, where: "(state = 2 AND (verification_state IN (0, 3)))", name: NEEDS_VERIFICATION_INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :snippet_repository_registry, PENDING_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name :snippet_repository_registry, FAILED_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name :snippet_repository_registry, NEEDS_VERIFICATION_INDEX_NAME
  end
end
