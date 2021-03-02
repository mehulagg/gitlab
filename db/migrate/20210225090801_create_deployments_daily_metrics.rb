# frozen_string_literal: true

class CreateDeploymentsDailyMetrics < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    create_table :dora_daily_metrics, id: false do |t|
      t.references :environment, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.date :date, null: false
      t.integer :deployment_frequency
      t.integer :lead_time_for_changes
    end

    add_index :dora_daily_metrics, [:environment_id, :date], unique: true
  end

  def down
    drop_table :dora_daily_metrics
  end
end
