# frozen_string_literal: true

module Ci
  class DailyBuildGroupReportResult < ApplicationRecord
    extend Gitlab::Ci::Model

    PARAM_TYPES = %w[coverage].freeze

    belongs_to :last_pipeline, class_name: 'Ci::Pipeline', foreign_key: :last_pipeline_id
    belongs_to :project

    validates :data, json_schema: { filename: "daily_build_group_report_result_data" }

    scope :with_included_projects, -> { includes(:project) }
    scope :by_projects, -> (ids) { where(project_id: ids) }
    scope :with_coverage, -> { where("(data->'coverage') IS NOT NULL") }
    scope :latest, -> do
      with(
        latest_by_project: select(:project_id, 'MAX(date) AS date').group(:project_id)
      )
      .joins(
        'JOIN latest_by_project ON ci_daily_build_group_report_results.date = latest_by_project.date
        AND ci_daily_build_group_report_results.project_id = latest_by_project.project_id'
      )
    end

    # Move this to EE
    def self.activity_per_group
      group(:date).pluck(
        Arel.sql("AVG(cast(data ->> 'coverage' AS FLOAT))"),
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

    def self.upsert_reports(data)
      upsert_all(data, unique_by: :index_daily_build_group_report_results_unique_columns) if data.any?
    end

    def self.recent_results(attrs, limit: nil)
      where(attrs).order(date: :desc, group_name: :asc).limit(limit)
    end
  end
end
