# frozen_string_literal: true

# DailyBuildGroupReportResultsFinder
#
# Used to filter DailyBuildGroupReportResults by set of params
#
# Arguments:
#   current_user
#   params:
#     project: integer
#     ref_path: string
#     start_date: date
#     limit: integer
#
module Ci
  class DailyBuildGroupReportResultsFinder
    include Gitlab::Allowable

    attr_accessor :params
    attr_reader :current_user


    def initialize(params: {}, current_user: nil)
      @params = params
      @current_user = current_user
    end

    def execute
      return none unless query_allowed?

      binding.pry
      collection = Ci::DailyBuildGroupReportResult.recent_results(query_params, limit: params[:limit])
      collection = filter_report_results(collection)
    end

    private

    def filter_report_results(collection)
      collection = by_projects_ids(collection)
      collection = by_coverage(collection)
      collection = by_ref_path(collection)
      collection = by_date(collection)
      collection
    end

    def by_projects_ids(items)
      params[:project_ids].present? ? items.by_projects(params[:project_ids]) : items
    end

    def by_coverage(items)
      params[:coverage].present? ? items.with_coverage : items
    end

    def by_ref_path(items)
      params[:ref_path].present? ? items.where(ref_path: params[:ref_path]) : items.with_default_branch
    end

    def by_date(items)
      params[:start_date].present? ? items.by_date(params[:start_date]) : items
    end

    def query_allowed?
      can?(current_user, :read_build_report_results, params[:project])
    end

    def query_params
      {
        project_id: params[:project],
        ref_path: params[:ref_path] || nil,
        date: Date.parse(params[:start_date])..Date.current
      }
    end

    def none
      Ci::DailyBuildGroupReportResult.none
    end
  end
end
