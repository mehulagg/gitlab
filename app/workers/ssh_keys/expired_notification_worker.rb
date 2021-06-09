# frozen_string_literal: true

module SshKeys
  class ExpiredNotificationWorker
    include ApplicationWorker

    sidekiq_options retry: 3
    include CronjobQueue

    feature_category :compliance_management
    tags :exclude_from_kubernetes
    idempotent!

    def perform
      return unless ::Feature.enabled?(:ssh_key_expiration_email_notification, default_enabled: :yaml)

      # rubocop:disable CodeReuse/ActiveRecord
      Key.expired_and_not_notified.find_in_batches(batch_size: 1000) do |relation|
        users = User.where(id: relation.pluck(:user_id))

        users.each do |user|
          with_context(user: user) do
            Keys::ExpiryNotificationService.new(user, { keys: user.expired_and_unnotified_keys, expiring_soon: false }).execute
          end
        end
      end
      # rubocop:enable CodeReuse/ActiveRecord
    end
  end
end
