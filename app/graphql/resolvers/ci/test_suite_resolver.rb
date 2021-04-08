# frozen_string_literal: true

module Resolvers
  module Ci
    class TestSuiteResolver < BaseResolver
      type ::Types::Ci::TestSuiteType, null: true

      alias_method :pipeline, :object

      argument :build_ids, [GraphQL::ID_TYPE],
        required: true,
        description: 'IDs of the builds used to run the test suite.'

      def resolve(build_ids:)
        builds = pipeline.latest_builds.id_in(build_ids).presence
        return nil if builds.nil? || builds.empty?

        suite = builds.map do |build|
          build.collect_test_reports!(Gitlab::Ci::Reports::TestReports.new)
        end.sum

        Gitlab::Ci::Reports::TestFailureHistory.new(suite.failed.values, pipeline.project).load!

        TestSuiteSerializer
          .new(project: pipeline.project, current_user: @current_user)
          .represent(suite, details: true)
      end
    end
  end
end
