# frozen_string_literal: true

class RemoveTerraformStateVerificationColumns < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    remove_column :terraform_states, :verification_retry_at, :datetime_with_timezone
    remove_column :terraform_states, :verified_at, :datetime_with_timezone
    remove_column :terraform_states,  :verification_retry_count, :integer, limit: 2
    remove_column :terraform_states, :verification_checksum, :binary, using: 'verification_checksum::bytea'
    remove_column :terraform_states, :verification_failure, :text
  end
end
