# frozen_string_literal: true

module Mutations
  module RequirementsManagement
    class ExportRequirements < BaseMutation
      include FindsProject
      include CommonRequirementArguments

      graphql_name 'ExportRequirements'

      authorize :export_requirements

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Full project path the requirements are associated with.'

      def resolve(args)
        project_path = args.delete(:project_path)
        project = authorized_find!(project_path)
        IssuableExportCsvWorker.perform_async(:requirement, current_user.id, project.id, args)

        {
          errors: []
        }
      end
    end
  end
end
