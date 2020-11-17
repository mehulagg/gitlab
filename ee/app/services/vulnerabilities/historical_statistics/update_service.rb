# frozen_string_literal: true

module Vulnerabilities
  module HistoricalStatistics
    class UpdateService
      VULNERABILITY_STATISTIC_ATTRIBUTES = %w(total critical high medium low unknown info letter_grade).freeze

      def self.update_for(project)
        new(project).execute
      end

      def initialize(project)
        @project = project
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def execute
        return if vulnerability_statistic.blank?

        ::Vulnerabilities::HistoricalStatistic.safe_ensure_unique(retries: 1) do
          historical_statistic = vulnerability_historical_statistics.find_or_initialize_by(date: vulnerability_statistic.updated_at)
          historical_statistic.update(vulnerability_statistic.attributes.slice(*VULNERABILITY_STATISTIC_ATTRIBUTES))
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      private

      attr_reader :project

      delegate :vulnerability_statistic, :vulnerability_historical_statistics, to: :project
    end
  end
end
