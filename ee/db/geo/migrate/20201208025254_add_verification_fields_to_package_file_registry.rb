# frozen_string_literal: true

class AddVerificationFieldsToPackageFileRegistry < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :package_file_registry, :verification_state, :integer, default: 0, limit: 2, null: false
    add_column :package_file_registry, :verification_started_at, :datetime_with_timezone
  end
end
