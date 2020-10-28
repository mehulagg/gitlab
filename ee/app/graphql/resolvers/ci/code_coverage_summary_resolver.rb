# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeCoverageSummaryResolver < BaseResolver
      # type ::Types::Ci::CodeCoverageSummaryType, null: true

      alias_method :project, :object

      def resolve(**args)
        # return unless Ability.allowed?(current_user, :read_build_report_results, project)
        BatchLoader::GraphQL.for(project.id).batch do |project_ids, loader|
          results = ::Ci::DailyBuildGroupReportResult
            .by_projects(project_ids)
            .with_coverage
            .latest
            .summaries_per_project

          results.each do |project_id, summary|
            loader.call(project_id, summary)
          end
        end
      end
    end
  end
end
