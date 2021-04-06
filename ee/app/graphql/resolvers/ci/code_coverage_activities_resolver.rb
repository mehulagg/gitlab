# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeCoverageActivitiesResolver < BaseResolver
      type ::Types::Ci::CodeCoverageActivityType, null: true

      argument :start_date, Types::DateType,
                required: true,
                description: 'First day for which to fetch code coverage activity (maximum time window is set to 90 days).'

      alias_method :group, :object

      def resolve(**args)
        code_coverage_params = params(args)

        ::Ci::DailyBuildGroupReportResultsFinder.new(
          params: code_coverage_params,
          current_user: current_user
        ).execute
      end

      private

      def params(args)
        {
          group: group,
          coverage: true,
          start_date: args.dig(:start_date).to_s,
          end_date: Date.current.to_s,
          group_activity: true
        }
      end
    end
  end
end
