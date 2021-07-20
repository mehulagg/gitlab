# frozen_string_literal: true

module EE
  module Ci
    # DailyBuildGroupReportResultsFinder
    #
    # Extends DailyBuildGroupReportResultsFinder
    #
    # Added arguments:
    #   params:
    #     group: integer
    #     group_activity: boolean
    #
    module DailyBuildGroupReportResultsFinder
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        return super unless params[:group]
        return ::Ci::DailyBuildGroupReportResult.none unless query_allowed?

        collection = ::Ci::DailyBuildGroupReportResult.by_group(params[:group])
        filter_report_results(collection)
      end

      private

      override :filter_report_results
      def filter_report_results(collection)
        collection = super(collection)
        by_activity_per_group(collection)
      end

      def by_activity_per_group(items)
        params[:group_activity].present? ? items.activity_per_group : items
      end

      override :query_allowed?
      def query_allowed?
        return super unless params[:group]

        can?(current_user, :read_group_build_report_results, params[:group])
      end
    end
  end
end
