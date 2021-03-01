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
    module DailyBuildGroupReportResultsFinder
      extend ::Gitlab::Utils::Override

      override :execute
      def execute
        return super unless params[:group]
        return ::Ci::DailyBuildGroupReportResult.none unless query_allowed?

        collection = ::Ci::DailyBuildGroupReportResult.by_group(params[:group])
        collection = filter_report_results(collection)
        collection
      end

      private

      override :query_allowed?
      def query_allowed?
        return super unless params[:group]

        can?(current_user, :read_group_build_report_results, params[:group])
      end
    end
  end
end
