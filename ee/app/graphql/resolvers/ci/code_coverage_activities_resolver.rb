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
        project_ids = group.projects.select(:id)
        start_date = args[:start_date].to_s

        ::Ci::DailyBuildGroupReportResult
          .with_included_projects
          .by_projects(project_ids)
          .with_coverage
          .with_default_branch
          .by_date(start_date)
          .activity_per_group
      end
    end
  end
end
