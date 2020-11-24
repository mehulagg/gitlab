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

      # Status of the monthly allowance being used.
      def monthly_minutes_report
        if namespace.shared_runners_minutes_limit_enabled? # TODO: try to refactor this
          status = monthly_minutes_used_up? ? :over_quota : :under_quota
          Report.new(monthly_minutes_used, monthly_minutes, status)
        else
          Report.new(monthly_minutes_used, 'Unlimited', :disabled)
        end
      end

      def monthly_percent_used
        return 0 unless namespace.shared_runners_minutes_limit_enabled?
        return 0 if monthly_minutes == 0

        100 * monthly_minutes_used.to_i / monthly_minutes
      end

      # Status of any purchased minutes used.
      def purchased_minutes_report
        status = purchased_minutes_used_up? ? :over_quota : :under_quota
        Report.new(purchased_minutes_used, purchased_minutes, status)
      end

      def purchased_percent_used
        return 0 unless namespace.shared_runners_minutes_limit_enabled?
        return 0 if purchased_minutes == 0

        100 * purchased_minutes_used.to_i / purchased_minutes
      end

      def minutes_used_up?
        namespace.shared_runners_minutes_limit_enabled? &&
          total_minutes_used >= total_minutes
      end

      private

      def monthly_minutes_used_up?
        namespace.shared_runners_minutes_limit_enabled? &&
          monthly_minutes_used >= monthly_minutes
      end

      def purchased_minutes_used_up?
        namespace.shared_runners_minutes_limit_enabled? &&
          any_minutes_purchased? &&
          purchased_minutes_used >= purchased_minutes
      end

      # TODO: maps to NamespaceStatistics#shared_runners_minutes(include_extra: false)
      def monthly_minutes_used
        total_minutes_used - purchased_minutes_used
      end

      def monthly_minutes_available?
        total_minutes_used <= monthly_minutes
      end

      # TODO: maps to NamespaceStatistics#extra_shared_runners_minutes
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

      # TODO: maps to Namespace#actual_shared_runners_minutes_limit(include_extra: true)
      def total_minutes
        @total_minutes ||= monthly_minutes + purchased_minutes
      end

      # TODO: maps to NamespaceStatistics#shared_runners_minutes(include_extra: true)
      def total_minutes_used
        @total_minutes_used ||= namespace.shared_runners_seconds.to_i / 60
      end

      # TODO: maps to Namespace#actual_shared_runners_minutes_limit(include_extra: false)
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
