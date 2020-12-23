# frozen_string_literal: true

module Mutations
  module RequirementsManagement
    class ExportRequirements < BaseMutation
      include ResolvesProject

      graphql_name 'ExportRequirements'

      authorize :export_requirements

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Full project path the requirements are associated with.'

      argument :sort, Types::SortEnum,
               required: false,
               description: 'List requirements by sort order.'

      argument :state, Types::RequirementsManagement::RequirementStateEnum,
               required: false,
               description: 'Filter requirements by state.'

      argument :search, GraphQL::STRING_TYPE,
               required: false,
               description: 'Search query for requirement title.'

      argument :author_username, [GraphQL::STRING_TYPE],
               required: false,
               description: 'Filter requirements by author username.'

      def resolve(args)
        project_path = args.delete(:project_path)
        project = authorized_find!(full_path: project_path)
        IssuableExportCsvWorker.perform_async(:requirement, current_user.id, project.id, args)

        {
          errors: []
        }
      end

      private

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end

# mutation {
#   exportRequirements(input: {projectPath: "group-1/project-1", search: "lala", authorUsername: ["root"], state: OPENED}) {
#     errors
#   }
# }
