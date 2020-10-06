# frozen_string_literal: true

module Types
  module Ci
    class CodeCoverageType < BaseObject
      graphql_name 'CodeCoverage'
      description 'Represents the daily code coverage for a project'

      alias_method :code_coverages, :object

      # authorize :read_build_report_results

      field :average_coverage, GraphQL::FLOAT_TYPE, null: true,
            description: 'Percentage of coverage for the project'

      field :coverage_count, GraphQL::INT_TYPE, null: true,
            description: 'Number of coverages for the project'

      field :last_updated_at, Types::TimeType, null: true,
            description: 'Latest date of coverage for the project'

      def last_updated_at
        code_coverages&.last&.date
      end
    end
  end
end
