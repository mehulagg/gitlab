# frozen_string_literal: true

class AddSecurityDashboardAccessLevelIntoProjectFeatures < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :project_features, :security_dashboard_access_level, :integer, default: Gitlab::Access::DEVELOPER, null: false
  end
end
