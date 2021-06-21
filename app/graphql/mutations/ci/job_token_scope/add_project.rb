# frozen_string_literal: true

module Mutations
  module Ci
    module JobTokenScope
      class AddProject < BaseMutation
        include FindsProject
        include ResolvesProject

        graphql_name 'CiJobTokenScopeAddProject'

        authorize :admin_project

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project that the CI job token scope belongs to.'

        argument :target_project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to be added to the CI job token scope.'

        field :ci_job_token_scope,
          Types::Ci::JobTokenScopeType,
          null: true,
          description: 'The CI Job Tokens scope of access.'

        def resolve(project_path:, target_project_path:)
          project = authorized_find!(project_path)
          target_project = resolve_project(full_path: target_project_path).sync

          result = ::Ci::JobTokenScope::AddProjectService
            .new(project, current_user)
            .execute(target_project)

          if result.success?
            {
              ci_job_token_scope: resolved_scope(project),
              errors: []
            }
          else
            {
              ci_job_token_scope: nil,
              errors: [result.message]
            }
          end
        end

        private

        def resolved_scope(project)
          Resolvers::Ci::JobTokenScopeResolver
            .new(object: project, context: context, field: nil)
            .resolve
        end
      end
    end
  end
end
