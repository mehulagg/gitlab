# frozen_string_literal: true

class AddVerificationIndexesToPagesDeployments < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  VERIFICATION_STATE_INDEX_NAME = "index_pages_deployments_on_verification_state"
  PENDING_VERIFICATION_INDEX_NAME = "index_pages_deployments_pending_verification"
  FAILED_VERIFICATION_INDEX_NAME = "index_pages_deployments_failed_verification"
  NEEDS_VERIFICATION_INDEX_NAME = "index_pages_deployments_needs_verification"

  disable_ddl_transaction!

  def up
    add_concurrent_index :pages_deployments, :verification_state, name: VERIFICATION_STATE_INDEX_NAME
    add_concurrent_index :pages_deployments, :verified_at, where: "(verification_state = 0)", order: { verified_at: 'ASC NULLS FIRST' }, name: PENDING_VERIFICATION_INDEX_NAME
    add_concurrent_index :pages_deployments, :verification_retry_at, where: "(verification_state = 3)", order: { verification_retry_at: 'ASC NULLS FIRST' }, name: FAILED_VERIFICATION_INDEX_NAME
    add_concurrent_index :pages_deployments, :verification_state, where: "(verification_state = 0 OR verification_state = 3)", name: NEEDS_VERIFICATION_INDEX_NAME
  end

  def down
    remove_concurrent_index_by_name :pages_deployments, VERIFICATION_STATE_INDEX_NAME
    remove_concurrent_index_by_name :pages_deployments, PENDING_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name :pages_deployments, FAILED_VERIFICATION_INDEX_NAME
    remove_concurrent_index_by_name :pages_deployments, NEEDS_VERIFICATION_INDEX_NAME
  end
end
