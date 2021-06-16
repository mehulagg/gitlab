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
                 description: 'The project that defines the CI job token scope.'

        argument :target_project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to be added to the CI job token scope.'

        field :target_project,
          Types::ProjectType,
          null: true,
          description: 'The project added to the job token scope.'

        def resolve(project_path:, target_project_path:)
          project = authorized_find!(project_path)
          target_project = resolve_project(full_path: target_project_path).sync

          result = ::Ci::JobTokenScope::AddProjectService
            .new(project, current_user)
            .execute(target_project)

          if result.success?
            {
              target_project: target_project,
              errors: []
            }
          else
            {
              target_project: nil,
              errors: [result.message]
            }
          end
        end
      end
    end
  end
end
