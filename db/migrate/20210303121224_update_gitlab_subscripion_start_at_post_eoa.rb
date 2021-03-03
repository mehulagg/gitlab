# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class UpdateGitlabSubscripionStartAtPostEoa < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  # include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def up
    # Silver to Premium
    update_hosted_plan_for_subscription(from_plan: silver_plan, to_plan: premium_plan)

    # Gold to Ultimate
    update_hosted_plan_for_subscription(from_plan: gold_plan, to_plan: ultimate_plan)
  end

  def down
    # Premium back to Silver
    update_hosted_plan_for_subscription(from_plan: premium_plan, to_plan: silver_plan)

    # Ultimate back to Gold
    update_hosted_plan_for_subscription(from_plan: ultimate_plan, to_plan: gold_plan)
  end

  private

  def update_hosted_plan_for_subscription(from_plan:, to_plan:)
    update_column_in_batches(:gitlab_subscriptions, :hosted_plan_id, from_plan.id) do |table, query|
      query.where('start_date >= ? AND hosted_plan_id = ?', eoa_rollout_date, to_plan.id )
    end
  end

  def eoa_rollout_date
    @eoa_rollout_date ||= GitlabSubscription::EOA_ROLLOUT_DATE.to_date
  end

  def silver_plan
    @silver_plan ||= Plan.find_by(name: 'silver')
  end

  def gold_plan
    @gold_plan ||= Plan.find_by(name: 'gold')
  end

  def premium_plan
    @premium_plan ||= Plan.find_by(name: 'premium')
  end

  def ultimate_plan
    @ultimate_plan ||= Plan.find_by(name: 'ultimate')
  end
end
