# frozen_string_literal: true

class AddOnExpiryNotificationDeliveredToKeys < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :keys, :on_expiry_notification_delivered, :boolean, null: false, default: false
  end
end
