# frozen_string_literal: true

class InsertRunnerRegistrationPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    return unless Gitlab.com?

    create_or_update_plan_limit('registered_runners', 'free', 100)
    create_or_update_plan_limit('registered_runners', 'bronze', 1000)
    create_or_update_plan_limit('registered_runners', 'silver', 10000)
    create_or_update_plan_limit('registered_runners', 'gold', 10000)
  end

  def down
    return unless Gitlab.com?

    create_or_update_plan_limit('registered_runners', 'free', 0)
    create_or_update_plan_limit('registered_runners', 'bronze', 0)
    create_or_update_plan_limit('registered_runners', 'silver', 0)
    create_or_update_plan_limit('registered_runners', 'gold', 0)
  end
end
