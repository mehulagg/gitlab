# frozen_string_literal: true

class InsertDailyPipelineScheduleTriggersPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  EVERY_10_MINUTES = 24 * 60 / 10
  EVERY_HOUR = 24

  def up
    return unless Gitlab.com?

    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'free', EVERY_HOUR)
    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'bronze', EVERY_10_MINUTES)
    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'silver', EVERY_10_MINUTES)
    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'gold', EVERY_10_MINUTES)
  end

  def down
    return unless Gitlab.com?

    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'free', 0)
    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'bronze', 0)
    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'silver', 0)
    create_or_update_plan_limit('daily_pipeline_schedule_triggers', 'gold', 0)
  end
end
