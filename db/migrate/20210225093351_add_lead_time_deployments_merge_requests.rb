# frozen_string_literal: true

class AddLeadTimeDeploymentsMergeRequests < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :deployment_merge_requests, :lead_time_to_deploy, :integer
    end
  end

  def down
    with_lock_retries do
      remove_column :deployment_merge_requests, :lead_time_to_deploy
    end
  end
end
