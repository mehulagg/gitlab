# frozen_string_literal: true

class AddVerificationStateAndStartedAtToTerraformStateVersionTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_table(:terraform_state_versions) do |t|
      t.integer :verification_state, default: 0, limit: 2, null: false
      t.column :verification_started_at, :datetime_with_timezone
    end
  end
end
