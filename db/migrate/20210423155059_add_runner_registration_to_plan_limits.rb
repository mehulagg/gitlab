# frozen_string_literal: true

class AddRunnerRegistrationToPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column(:plan_limits, :registered_runners, :integer, default: 0, null: false)
    end
  end

  def down
    with_lock_retries do
      remove_column(:plan_limits, :registered_runners) if column_exists?(:plan_limits, :registered_runners)
    end
  end
end
