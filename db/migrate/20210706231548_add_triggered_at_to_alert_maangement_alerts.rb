# frozen_string_literal: true

class AddTriggeredAtToAlertMaangementAlerts < ActiveRecord::Migration[6.1]
  def change
    add_column :alert_management_alerts, :triggered_at, :datetime_with_timezone
  end
end
