# frozen_string_literal: true

module Ci
  module Minutes
    class EmailNotificationService < ::BaseService
      def execute
        @notification = ::Ci::Minutes::Notification.new(project, nil)

        # TODO: this introduces a change in the logic that it seems to be the right behavior:
        # - before: we were checking if the root namespace of the project had shared runners
        #   minutes limit enabled, regardless whether the project had shared runners enabled.
        # - after: we check if the project is eligible for shared runners minutes. If the project
        #   has shared runners disabled we won't send a notification. This means we would also
        #   avoid unnecessary computations.
        return unless notification.eligible_for_notifications?

        notify
      end

      private

      attr_reader :notification

      def notify
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
