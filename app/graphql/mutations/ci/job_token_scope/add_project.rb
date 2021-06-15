# frozen_string_literal: true

module Mutations
  module Ci
    module JobTokenScope
      class AddProject < BaseMutation
        include FindsProject
        include ResolvesProject

        graphql_name 'JobTokenScopeAddProject'

        authorize :admin_project

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project the job token scope is being updated.'

        argument :target_project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to be added to the job token scope.'

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

        private

        def raise_target_project_not_found!
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'The target project could not be found'
        end
      end
    end
  end
end
