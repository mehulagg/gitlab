# frozen_string_literal: true

class AddCiJobTraceSizeToPlanLimits < ActiveRecord::Migration[6.1]
  def change
    add_column(:plan_limits, :ci_job_trace_size, :integer, default: 100, null: false)
  end
end
