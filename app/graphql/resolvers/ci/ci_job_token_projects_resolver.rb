# frozen_string_literal: true

module Resolvers
  module Ci
    class CiJobTokenProjectsResolver < BaseResolver
      description 'Allowed projects that can use a project CI Job Token.'

      type ::Types::ProjectType.connection_type, null: true

      def resolve
        ci_job_token = ::Ci::JobToken::Scope.new(object)

        ci_job_token.all_projects
      end
    end
  end
end
