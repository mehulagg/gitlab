# frozen_string_literal: true

class AddExpirationPolicyCleanupStatusToContainerRepositories < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'idx_container_repositories_on_exp_cleanup_status_and_start_date'

  disable_ddl_transaction!

  def up
    add_column(:container_repositories, :expiration_policy_cleanup_status, :integer, limit: 2)
    add_concurrent_index(:container_repositories, [:expiration_policy_cleanup_status, :expiration_policy_started_at], name: INDEX_NAME)
  end

  def down
    remove_concurrent_index(:container_repositories, [:expiration_policy_cleanup_status, :expiration_policy_started_at], name: INDEX_NAME)
    remove_column(:container_repositories, :expiration_policy_cleanup_status)
  end
end
