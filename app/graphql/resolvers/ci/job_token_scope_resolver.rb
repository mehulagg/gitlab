# frozen_string_literal: true

module Resolvers
  module Ci
    class JobTokenScopeResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      authorize :admin_project
      description 'Projects that can be accessed by a CI job token from the current project. Null if job token scope setting is disabled.'
      type ::Types::ProjectType.connection_type, null: true

      def resolve
        authorize!(object)

        return unless object.ci_job_token_scope_enabled?

        ::Ci::JobToken::Scope.new(object).all_projects
      end
    end
  end
end
