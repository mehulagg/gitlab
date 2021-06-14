# frozen_string_literal: true

class AddVerificationStateToLfsObjectsTable < ActiveRecord::Migration[6.1]
  def change
    change_table(:lfs_objects) do |t|
      t.column :verification_retry_at, :datetime_with_timezone
      t.column :verification_started_at, :datetime_with_timezone
      t.column :verified_at, :datetime_with_timezone
      t.integer :verification_state, default: 0, limit: 2, null: false
      t.integer :verification_retry_count, limit: 2
      t.binary :verification_checksum, using: 'verification_checksum::bytea'
      t.column :verification_failure, :string, limit: 255 # rubocop:disable Migration/PreventStrings because https://gitlab.com/gitlab-org/gitlab/-/issues/323806
    end
  end
end
