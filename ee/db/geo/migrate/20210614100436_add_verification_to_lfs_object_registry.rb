# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddVerificationToLfsObjectRegistry < ActiveRecord::Migration[6.1]
  def change
    add_column :lfs_object_registry, :verification_started_at, :datetime_with_timezone
    add_column :lfs_object_registry, :verified_at, :datetime_with_timezone
    add_column :lfs_object_registry, :verification_retry_at, :datetime_with_timezone
    add_column :lfs_object_registry, :verification_retry_count, :integer, default: 0
    add_column :lfs_object_registry, :verification_state, :integer, limit: 2, default: 0, null: false
    add_column :lfs_object_registry, :checksum_mismatch, :boolean, default: false, null: false
    add_column :lfs_object_registry, :verification_checksum, :binary
    add_column :lfs_object_registry, :verification_checksum_mismatched, :binary
    add_column :lfs_object_registry, :verification_failure, :string, limit: 255 # rubocop:disable Migration/PreventStrings because https://gitlab.com/gitlab-org/gitlab/-/issues/323806
  end
end
