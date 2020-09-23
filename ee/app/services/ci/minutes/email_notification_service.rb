# frozen_string_literal: true

module Ci
  module Minutes
    class EmailNotificationService < ::BaseService
      def execute
        return unless namespace.shared_runners_minutes_limit_enabled?

        notify
      end

      private

      attr_reader :notification

      def notify
        @notification = ::Ci::Minutes::Notification.new(project, nil)

        if notification.no_remaining_minutes?
          notify_total_usage
        elsif notification.running_out?
          notify_partial_usage
        end
      end

      def notify_total_usage
        return if namespace.last_ci_minutes_notification_at

        namespace.update_columns(last_ci_minutes_notification_at: Time.current)

        CiMinutesUsageMailer.notify(namespace, recipients).deliver_later
      end

      def notify_partial_usage
        return if already_notified_running_out

        namespace.update_columns(last_ci_minutes_usage_notification_level: current_alert_percentage)

        CiMinutesUsageMailer.notify_limit(namespace, recipients, current_alert_percentage).deliver_later
      end

      def already_notified_running_out
        namespace.last_ci_minutes_usage_notification_level == current_alert_percentage
      end

      def recipients
        namespace.user? ? [namespace.owner_email] : namespace.owners_emails
      end

      def namespace
        @namespace ||= project.shared_runners_limit_namespace
      end

      def current_alert_percentage
        notification.stage_percentage
      end
    end
  end
end
