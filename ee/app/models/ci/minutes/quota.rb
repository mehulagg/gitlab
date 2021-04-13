# frozen_string_literal: true

# This class provides current status of Shared Runners minutes usage for a namespace
# taking in consideration the monthly minutes allowance that Gitlab.com provides and
# any possible purchased minutes.

module Ci
  module Minutes
    class Quota
      Report = Struct.new(:used, :limit, :status)

      def initialize(namespace)
        @namespace = namespace
      end

      def enabled?
        namespace_eligible? && total_minutes.nonzero?
      end

      # Status of the monthly allowance being used.
      def monthly_minutes_report
        Report.new(monthly_minutes_used, minutes_limit, report_status)
      end

      def monthly_percent_used
        return 0 unless enabled?
        return 0 if monthly_minutes == 0

        100 * monthly_minutes_used.to_i / monthly_minutes
      end

      # Status of any purchased minutes used.
      def purchased_minutes_report
        status = purchased_minutes_used_up? ? :over_quota : :under_quota
        Report.new(purchased_minutes_used, purchased_minutes, status)
      end

      def purchased_percent_used
        return 0 unless enabled?
        return 0 if purchased_minutes == 0

        100 * purchased_minutes_used.to_i / purchased_minutes
      end

      def minutes_used_up?
        enabled? && total_minutes_used >= total_minutes
      end

      def total_minutes
        @total_minutes ||= monthly_minutes + purchased_minutes
      end

      def total_minutes_remaining
        [(total_minutes.to_i - accurate_total_minutes_used).round(2), 0].max
      end

      # TODO: deprecate this method in favor of accurate_total_minutes_used
      # which will eventually point to Ci::Minutes::NamespaceMonthlyUsage#amount_used
      # https://gitlab.com/gitlab-org/gitlab/-/issues/277448
      def total_minutes_used
        @total_minutes_used ||= namespace.shared_runners_seconds.to_i / 60
      end

      def percent_total_minutes_remaining
        return 0 if total_minutes == 0

        100 * total_minutes_remaining.to_i / total_minutes
      end

      def namespace_eligible?
        namespace.root? && namespace.any_project_with_shared_runners_enabled?
      end

      private

      # Equivalent to Ci::Minutes::BuildConsumption#amount
      def accurate_total_minutes_used
        @accurate_total_minutes_used ||= (namespace.shared_runners_seconds.to_f / 60).round(2)
      end

      def minutes_limit
        return monthly_minutes if enabled?

        if namespace_eligible?
          _('Unlimited')
        else
          _('Not supported')
        end
      end

      def report_status
        return :disabled unless enabled?

        monthly_minutes_used_up? ? :over_quota : :under_quota
      end

      def monthly_minutes_used_up?
        return false unless enabled?

        monthly_minutes_used >= monthly_minutes
      end

      def purchased_minutes_used_up?
        return false unless enabled?

        any_minutes_purchased? && purchased_minutes_used >= purchased_minutes
      end

      def monthly_minutes_used
        total_minutes_used - purchased_minutes_used
      end

      def monthly_minutes_available?
        total_minutes_used <= monthly_minutes
      end

      def purchased_minutes_used
        return 0 if no_minutes_purchased? || monthly_minutes_available?

        total_minutes_used - monthly_minutes
      end

      def no_minutes_purchased?
        purchased_minutes == 0
      end

      def any_minutes_purchased?
        purchased_minutes > 0
      end

      def monthly_minutes
        @monthly_minutes ||= (namespace.shared_runners_minutes_limit || ::Gitlab::CurrentSettings.shared_runners_minutes).to_i
      end

      def purchased_minutes
        @purchased_minutes ||= namespace.extra_shared_runners_minutes_limit.to_i
      end

      attr_reader :namespace
    end
  end
end
