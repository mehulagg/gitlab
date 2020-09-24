# frozen_string_literal: true

class AddVerificationFieldsToPackageFileOnSecondary < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :package_file_registry, :verification_failure, :string, limit: 255 # rubocop:disable Migration/PreventStrings
    add_column :package_file_registry, :verification_checksum, :binary
    add_column :package_file_registry, :checksum_mismatch, :boolean
    add_column :package_file_registry, :verification_checksum_mismatched, :binary
    add_column :package_file_registry, :verification_retry_count, :integer
    add_column :package_file_registry, :verified_at, :datetime_with_timezone
    add_column :package_file_registry, :verification_retry_at, :datetime_with_timezone
  end
end
