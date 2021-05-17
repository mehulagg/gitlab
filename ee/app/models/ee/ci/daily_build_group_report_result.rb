# frozen_string_literal: true

module EE
  module Ci
    # Ci::DailyBuildGroupReportResult mixin
    #
    # This module is intended to encapsulate EE-specific model logic
    # and be prepended in the `Ci::DailyBuildGroupReportResult` model
    module DailyBuildGroupReportResult
      extend ActiveSupport::Concern

      prepended do
        scope :latest, -> do
          with(
            ::Gitlab::SQL::CTE.new(:latest_by_project, select(:project_id, 'MAX(date) AS date').group(:project_id)).to_arel
          )
          .joins(
            'JOIN latest_by_project ON ci_daily_build_group_report_results.date = latest_by_project.date
            AND ci_daily_build_group_report_results.project_id = latest_by_project.project_id'
          )
        end

        def self.summaries_per_project
          group(:project_id, 'latest_by_project.date').pluck(
            :project_id,
            Arel.sql("ROUND(AVG(CAST(data ->> 'coverage' AS DECIMAL)), 2)::FLOAT"),
            Arel.sql("COUNT(*)"),
            Arel.sql("latest_by_project.date")
          ).each_with_object({}) do |(project_id, average_coverage, coverage_count, date), result|
            result[project_id] = {
              average_coverage: average_coverage,
              coverage_count: coverage_count,
              last_updated_on: Date.parse(date.to_s)
            }
          end
        end

        def self.activity_per_group
          group(:date).pluck(
            Arel.sql("ROUND(AVG(CAST(data ->> 'coverage' AS DECIMAL)), 2)::FLOAT"),
            Arel.sql("COUNT(*)"),
            Arel.sql("COUNT(DISTINCT ci_daily_build_group_report_results.project_id)"),
            Arel.sql("date")
          )
          .each_with_object([]) do |(average_coverage, coverage_count, project_count, date), result|
            result << {
              average_coverage: average_coverage,
              coverage_count: coverage_count,
              project_count: project_count,
              date: date
            }
          end
        end
      end
    end
  end
end
