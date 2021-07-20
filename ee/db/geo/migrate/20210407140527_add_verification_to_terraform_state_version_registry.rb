# frozen_string_literal: true

class AddVerificationToTerraformStateVersionRegistry < ActiveRecord::Migration[6.0]
  def change
    add_column :terraform_state_version_registry, :verification_started_at, :datetime_with_timezone
    add_column :terraform_state_version_registry, :verified_at, :datetime_with_timezone
    add_column :terraform_state_version_registry, :verification_retry_at, :datetime_with_timezone
    add_column :terraform_state_version_registry, :verification_retry_count, :integer, default: 0
    add_column :terraform_state_version_registry, :verification_state, :integer, limit: 2, default: 0, null: false
    add_column :terraform_state_version_registry, :checksum_mismatch, :boolean, default: false, null: false
    add_column :terraform_state_version_registry, :verification_checksum, :binary
    add_column :terraform_state_version_registry, :verification_checksum_mismatched, :binary
    add_column :terraform_state_version_registry, :verification_failure, :string, limit: 255 # rubocop:disable Migration/PreventStrings because https://gitlab.com/gitlab-org/gitlab/-/issues/323806
  end
end
