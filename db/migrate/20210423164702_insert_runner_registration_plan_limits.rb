# frozen_string_literal: true

class InsertRunnerRegistrationPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_or_update_plan_limit('ci_registered_runners', 'default', 3)
    create_or_update_plan_limit('ci_registered_runners', 'free', 100)
    create_or_update_plan_limit('ci_registered_runners', 'bronze', 1000)
    create_or_update_plan_limit('ci_registered_runners', 'silver', 10000)
    create_or_update_plan_limit('ci_registered_runners', 'gold', 10000)
  end

  def down
    create_or_update_plan_limit('ci_registered_runners', 'default', 0)
    create_or_update_plan_limit('ci_registered_runners', 'free', 0)
    create_or_update_plan_limit('ci_registered_runners', 'bronze', 0)
    create_or_update_plan_limit('ci_registered_runners', 'silver', 0)
    create_or_update_plan_limit('ci_registered_runners', 'gold', 0)
  end
end
