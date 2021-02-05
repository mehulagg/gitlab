# frozen_string_literal: true

module Ci
  module Minutes
    # Track usage of Shared Runners minutes at root project level.
    # This class ensures that we keep 1 record per project per year-month.
    class ProjectMonthlyUsage < ApplicationRecord
      self.table_name = "ci_project_monthly_usages"

      belongs_to :project

      scope :current_month, -> {
        where("DATE_TRUNC('month', NOW()) AT TIME ZONE 'UTC' = DATE_TRUNC('month', ci_project_monthly_usages.created_at AT TIME ZONE 'UTC')")
      }

      # We should pretty much always use this method to access data for the current month
      # since this will lazily create an entry if it doesn't exist.
      # For example, on the 1st of each month, when we update the usage for a project,
      # we will automatically generate new records and reset usage for the current month.
      def self.current(project)
        current_month.safe_find_or_create_by(project: project)
      end

      def self.increase_usage(project, amount)
        return unless amount > 0

        # The use of `update_counters` ensures we do a SQL update rather than
        # incrementing the counter for the object in memory and then save it.
        # This is better for concurrent updates.
        update_counters(self.current(project), amount_used: amount)
      end
    end
  end
end
