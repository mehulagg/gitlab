# frozen_string_literal: true

module SshKeys
  class ExpiredNotificationWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :compliance_management

    def perform(*args)
      notification_service = NotificationService.new

      User.with_ssh_key_expired_today.find_each do |user|
        with_context(user: user) do
          Gitlab::AppLogger.info "#{self.class}: Notifying User #{user.id} about an expired key"

          notification_service.ssh_key_expired_email(user)

          user.ssh_keys.expired_today_and_not_notified.update_all(on_expiry_notification_delivered: true)
        end
      end
    end
  end
end
