# frozen_string_literal: true

module Ci
  module Minutes
    class NamespaceMonthlyUsage < ApplicationRecord
      self.table_name = "ci_namespace_monthly_usages"

      belongs_to :namespace

      scope :current_month, -> {
        where("DATE_TRUNC('month', NOW()) AT TIME ZONE 'UTC' = DATE_TRUNC('month', ci_namespace_monthly_usages.created_at AT TIME ZONE 'UTC')")
      }

      def self.current(namespace)
        current_month.find_by(namespace: namespace)
      end

      def self.increase_usage(namespace, amount)
        return unless amount > 0

        usage = current_month.find_or_create_by(namespace: namespace)

        self.update_counters(usage, amount_used: amount)
      end
    end
  end
end
