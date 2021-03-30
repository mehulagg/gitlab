# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddNewTrailPlans < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  class Plan < ActiveRecord::Base
    has_one :limits, class_name: 'PlanLimits', dependent: :destroy

    def actual_limits
      self.limits || self.build_limits
    end
  end

  class PlanLimits < ActiveRecord::Base
    belongs_to :plan
  end

  def create_plan_limits(plan_limit_name, plan)
    plan_limit = Plan.find_or_initialize_by(name: plan_limit_name).actual_limits.dup
    plan_limit.plan = plan
    plan_limit.save
  end

  def up
    return unless Gitlab.dev_env_org_or_com? || Gitlab.staging?

    ultimate_trial = Plan.create(name: 'ultimate-trial', title: 'Ultimate Trial')
    premium_trial = Plan.create(name: 'premium-trial', title: 'Premium Trial')

    create_plan_limits('gold', ultimate_trial)
    create_plan_limits('silver', premium_trial)
  end

  def down
    return unless Gitlab.dev_env_org_or_com? || Gitlab.staging?

    Plan.find_by(name: 'ultimate-trial')&.destroy
    Plan.find_by(name: 'premium-trial')&.destroy
  end
end
