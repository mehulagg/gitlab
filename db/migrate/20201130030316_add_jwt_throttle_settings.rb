# frozen_string_literal: true

class AddJwtThrottleSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    add_column :application_settings, :throttle_jwt_auth_enabled, :boolean, null: false, default: false
    add_column :application_settings, :throttle_jwt_auth_requests_per_period, :integer, default: 600
    add_column :application_settings, :throttle_jwt_auth_period_in_seconds, :integer, default: 60
  end

  def down
    remove_column :application_settings, :throttle_jwt_auth_enabled
    remove_column :application_settings, :throttle_jwt_auth_requests_per_period
    remove_column :application_settings, :throttle_jwt_auth_period_in_seconds
  end
end
