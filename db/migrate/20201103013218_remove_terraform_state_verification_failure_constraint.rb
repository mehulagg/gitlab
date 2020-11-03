# frozen_string_literal: true

class RemoveTerraformStateVerificationFailureConstraint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  VERIFICATION_FAILURE_INDEX = "terraform_states_verification_failure_partial"
  VERIFICATION_CHECKSUM_INDEX = "terraform_states_verification_checksum_partial"

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index_by_name :terraform_states, VERIFICATION_FAILURE_INDEX
    remove_concurrent_index_by_name :terraform_states, VERIFICATION_CHECKSUM_INDEX
    remove_text_limit :terraform_states, :verification_failure
  end

  def down
    add_concurrent_index :terraform_states, :verification_failure, where: "(verification_failure IS NOT NULL)", name: VERIFICATION_FAILURE_INDEX
    add_concurrent_index :terraform_states, :verification_checksum, where: "(verification_checksum IS NOT NULL)", name: VERIFICATION_CHECKSUM_INDEX
    add_text_limit :terraform_states, :verification_failure, 255
  end
end
