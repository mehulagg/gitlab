# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeCoverageResolver < BaseResolver
      type Types::Ci::CodeCoverageType, null: true

      alias_method :project, :object

      def resolve(**args)
        return ::Ci::DailyBuildGroupReportResult.none unless can_read_build_report_results?

        project.latest_coverages.ordered_by_unique_group_name
      end

      private

      def can_read_build_report_results?
        current_user.can?(:read_build_report_results, project)
      end
    end
  end
end
