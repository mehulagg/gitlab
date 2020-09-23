# frozen_string_literal: true

module Vulnerabilities
  module HistoricalStatistics
    class AdjustmentService
      TooManyProjectsError = Class.new(StandardError)

      UPSERT_SQL = <<~SQL
        INSERT INTO vulnerability_historical_statistics
          (project_id, total, info, unknown, low, medium, high, critical, letter_grade, date, created_at, updated_at)
          (%{stats_sql})
        ON CONFLICT (project_id, date)
        DO UPDATE SET
          total = EXCLUDED.total,
          info = EXCLUDED.info,
          unknown = EXCLUDED.unknown,
          low = EXCLUDED.low,
          medium = EXCLUDED.medium,
          high = EXCLUDED.high,
          critical = EXCLUDED.critical,
          letter_grade = EXCLUDED.letter_grade,
          updated_at = EXCLUDED.updated_at
      SQL

      STATS_SQL = <<~SQL
        SELECT
          project_id,
          total,
          info,
          unknown,
          low,
          medium,
          high,
          critical,
          letter_grade,
          updated_at AS date,
          now() AS created_at,
          now() AS updated_at
        FROM vulnerability_statistics
        WHERE project_id IN (%{project_ids})
      SQL

      MAX_PROJECTS = 1_000

      def self.execute(project_ids)
        new(project_ids).execute
      end

      def initialize(project_ids)
        raise TooManyProjectsError, "Cannot adjust statistics for more than #{MAX_PROJECTS} projects" if project_ids.size > MAX_PROJECTS

        @project_ids = project_ids.map { |id| Integer(id) }.join(', ')
      end

      def execute
        ApplicationRecord.connection.execute(upsert_sql)
      end

      private

      attr_reader :project_ids

      def upsert_sql
        UPSERT_SQL % { stats_sql: stats_sql }
      end

      def stats_sql
        STATS_SQL % { project_ids: project_ids }
      end
    end
  end
end
