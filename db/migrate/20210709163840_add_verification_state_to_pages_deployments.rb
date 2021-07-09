# frozen_string_literal: true

class AddVerificationStateToPagesDeployments < ActiveRecord::Migration[6.1]
  def change
    change_table(:pages_deployments) do |t|
      t.integer :verification_state, default: 0, limit: 2, null: false
      t.column :verification_started_at, :datetime_with_timezone
      t.integer :verification_retry_count, default: 0, limit: 2, null: false
      t.column :verification_retry_at, :datetime_with_timezone
      t.column :verified_at, :datetime_with_timezone
      t.binary :verification_checksum, using: 'verification_checksum::bytea'

      t.text :verification_failure # rubocop:disable Migration/AddLimitToTextColumns
    end
  end
end
