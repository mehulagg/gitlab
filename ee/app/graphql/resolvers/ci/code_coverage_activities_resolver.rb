# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeCoverageActivitiesResolver < BaseResolver
      type ::Types::Ci::CodeCoverageActivityType, null: true

      # prepended do
      #   argument :start_date, GraphQL::STRING_TYPE,
      #           required: false,
      #           description: 'start date'
      # end

      alias_method :group, :object

      def resolve(**args)
        project_ids = group.projects.pluck(:id)

        results = ::Ci::DailyBuildGroupReportResult
          .by_projects(project_ids)
          .with_coverage
          .latest
          .activity_per_group
      end
    end
  end
end

