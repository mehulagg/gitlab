# frozen_string_literal: true

class AddExpiryNotificationDeliveredToKeys < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def change
    add_column :keys, :before_expiry_notification_delivered, :boolean, null: false, default: false
    add_column :keys, :after_expiry_notification_delivered, :boolean, null: false, default: false
  end
end
