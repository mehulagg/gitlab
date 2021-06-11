# frozen_string_literal: true

module Resolvers
  module Ci
    class JobTokenScopeResolver < BaseResolver
      description 'Allowed projects that can use a project CI Job Token.'

      type ::Types::ProjectType.connection_type, null: true

      def resolve
        return unless object.job_token_scope_enabled?

        ci_job_token = ::Ci::JobToken::Scope.new(object).all_projects
      end
    end
  end
end
