# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddVerificationFieldsToPackageFileRegistry < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :package_file_registry, :verification_state, :integer, default: 0, limit: 2, null: false
    add_column :package_file_registry, :verification_started_at, :datetime_with_timezone
  end
end
