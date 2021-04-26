# frozen_string_literal: true

class AddRunnerRegistrationToPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column(:plan_limits, :ci_registered_instance_runners, :integer, default: 0, null: false)
      add_column(:plan_limits, :ci_registered_group_runners, :integer, default: 0, null: false)
      add_column(:plan_limits, :ci_registered_project_runners, :integer, default: 0, null: false)
    end
  end

  def down
    with_lock_retries do
      remove_column(:plan_limits, :ci_registered_instance_runners) if column_exists?(:plan_limits, :ci_registered_instance_runners)
      remove_column(:plan_limits, :ci_registered_group_runners) if column_exists?(:plan_limits, :ci_registered_group_runners)
      remove_column(:plan_limits, :ci_registered_project_runners) if column_exists?(:plan_limits, :ci_registered_project_runners)
    end
  end
end
