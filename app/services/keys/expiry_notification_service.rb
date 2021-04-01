# frozen_string_literal: true

module Keys
  class ExpiryNotificationService < ::Keys::BaseService
    attr_accessor :keys, :expiring_soon_notification

    def initialize(user, params)
      @keys = params[:keys]
      @expiring_soon = params[:expiring_soon_notification] || false

      super
    end

    def execute
      return unless allowed?

      trigger_notification

      mark_notified
    end

    private

    def allowed?
      user.can?(:receive_notifications)
    end

    def trigger_notification
      if expiring_soon_notification
        notification_service.ssh_key_expiring_soon(user, keys.map(&:fingerprint))
      else
        notification_service.ssh_key_expired(user, keys.map(&:fingerprint))
      end
    end

    def mark_notified
      if expiring_soon_notification
        keys.update_all(before_expiry_notification_delivered_at: Time.current.utc)
      else
        keys.update_all(expiry_notification_delivered_at: Time.current.utc)
      end
    end
  end
end
