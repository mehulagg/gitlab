# frozen_string_literal: true

class AddDailyPipelineScheduleTriggersToPlanLimits < ActiveRecord::Migration[6.0]
  def change
    add_column(:plan_limits, :daily_pipeline_schedule_triggers, :integer, default: 0, null: false)
  end
end
