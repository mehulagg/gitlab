# frozen_string_literal: true

module Vulnerabilities
  module HistoricalStatistics
    class DeletionService
      RETENTION_PERIOD_IN_DAYS = 365

      def self.execute
        new.execute
      end

      def execute
        ::Vulnerabilities::HistoricalStatistic
          .older_than(days: RETENTION_PERIOD_IN_DAYS)
          .each_batch { |relation| relation.delete_all }
      end
    end
  end
end
