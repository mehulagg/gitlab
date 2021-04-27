# frozen_string_literal: true

class InsertRunnerRegistrationPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    create_or_update_plan_limit('ci_registered_group_runners', 'free', 20)
    create_or_update_plan_limit('ci_registered_group_runners', 'bronze', 2000)
    create_or_update_plan_limit('ci_registered_group_runners', 'silver', 2000)
    create_or_update_plan_limit('ci_registered_group_runners', 'gold', 2000)

    create_or_update_plan_limit('ci_registered_project_runners', 'free', 5)
    create_or_update_plan_limit('ci_registered_project_runners', 'bronze', 100)
    create_or_update_plan_limit('ci_registered_project_runners', 'silver', 100)
    create_or_update_plan_limit('ci_registered_project_runners', 'gold', 100)
  end

  def down
    %w[group project].each do |scope|
      create_or_update_plan_limit("ci_registered_#{scope}_runners", 'default', 0)
      create_or_update_plan_limit("ci_registered_#{scope}_runners", 'free', 0)
      create_or_update_plan_limit("ci_registered_#{scope}_runners", 'bronze', 0)
      create_or_update_plan_limit("ci_registered_#{scope}_runners", 'silver', 0)
      create_or_update_plan_limit("ci_registered_#{scope}_runners", 'gold', 0)
    end
  end
end
