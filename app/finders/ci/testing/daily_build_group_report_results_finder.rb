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

module Ci
  module Testing
    class DailyBuildGroupReportResultsFinder
      include Gitlab::Allowable

      def initialize(params: {}, current_user: nil)
        @params = params
        @current_user = current_user
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def execute
        return Ci::DailyBuildGroupReportResult.none unless query_allowed?

        collection = if @params[:group]
                       Ci::DailyBuildGroupReportResult.where(group_id: @params[:group])
                     else
                       Ci::DailyBuildGroupReportResult.where(project_id: @params[:project])
                     end

        collection = filter_report_results(collection)
        collection
      end
      # rubocop: enable CodeReuse/ActiveRecord

      private

      def query_allowed?
        if @params[:group]
          can?(@current_user, :read_group_build_report_results, @params[:group])
        else
          can?(@current_user, :read_build_report_results, @params[:project])
        end
      end

      def filter_report_results(collection)
        collection = by_project_ids(collection)
        collection = by_coverage(collection)
        collection = by_ref_path(collection)
        collection = by_end_date(collection)
        # collection = by_date(collection)
        collection = by_limit(collection)
        collection
      end

      def by_project_ids(items)
        @params[:project_ids].present? ? items.by_projects(@params[:project_ids]) : items
      end

      def by_coverage(items)
        @params[:coverage].present? ? items.with_coverage : items
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def by_ref_path(items)
        @params[:ref_path].present? ? items.where(ref_path: @params[:ref_path]) : items.with_default_branch
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def by_end_date(items)
        @params[:end_date].present? ? items.by_end_date(@params[:end_date]) : items
      end

      def by_date(items)
        @params[:start_date].present? ? items.by_date(@params[:start_date]) : items
      end

      def by_limit(items)
        @params[:limit].present? ? items.limit(@params[:limit]) : items # rubocop: disable CodeReuse/ActiveRecord
      end
    end
  end
end
