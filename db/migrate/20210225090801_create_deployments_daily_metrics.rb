# frozen_string_literal: true

class CreateDeploymentsDailyMetrics < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    create_table :deployments_daily_metrics do |t|
      t.referece :project, null: false
      t.referece :environment, null: false
      t.date :date
      t.integer :deployments_count
    end

    add_index :deployments_daily_metrics, [:project_id, :environment_id], unique: true
  end

  def down
    drop_table :deployments_daily_metrics
  end
end
