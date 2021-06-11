# frozen_string_literal: true

module Resolvers
  module Ci
    class JobTokenScopeResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      authorize :admin_project
      description 'Allowed projects that can use a project CI Job Token.'
      type ::Types::ProjectType.connection_type, null: true

      def resolve
        authorize!(object)

        return unless object.ci_job_token_scope_enabled?

        ::Ci::JobToken::Scope.new(object).all_projects
      end
    end
  end
end
