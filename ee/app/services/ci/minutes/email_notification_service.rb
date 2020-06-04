# frozen_string_literal: true

module Ci
  module Minutes
    class EmailNotificationService < ::BaseService
      def execute
        return unless ::Gitlab.com?
        return unless namespace.shared_runners_minutes_limit_enabled?

        notify_on_total_usage
        notify_on_partial_usage
      end

      private

      def recipients
        namespace.user? ? [namespace.owner.email] : namespace.owners.pluck(:email) # rubocop:disable CodeReuse/ActiveRecord
      end

      def notify_on_total_usage
        return unless quota.minutes_used_up? && namespace.last_ci_minutes_notification_at.nil?

        namespace.update_columns(last_ci_minutes_notification_at: Time.current)

        CiMinutesUsageMailer.notify(namespace, recipients).deliver_later
      end

      def notify_on_partial_usage
        return if quota.minutes_used_up?
        return if namespace.last_ci_minutes_usage_notification_level == current_alert_level
        return if alert_levels.max < namespace.shared_runners_remaining_minutes_percent

        namespace.update_columns(last_ci_minutes_usage_notification_level: current_alert_level)

        CiMinutesUsageMailer.notify_limit(namespace, recipients, current_alert_level).deliver_later
      end

      def quota
        @quota ||= ::Ci::Minutes::Quota.new(namespace)
      end

      def namespace
        @namespace ||= project.shared_runners_limit_namespace
      end

      def alert_levels
        @alert_levels ||= EE::Namespace::CI_USAGE_ALERT_LEVELS.sort
      end

      def current_alert_level
        remaining_percent = namespace.shared_runners_remaining_minutes_percent

        @current_alert_level ||= alert_levels.find { |level| level >= remaining_percent }
      end
    end
  end
end
