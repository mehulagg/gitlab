# frozen_string_literal: true

module Mutations
  module JiraImport
    class Start < BaseMutation
      include Mutations::ResolvesProject

      graphql_name 'JiraImportStart'

      field :jira_import,
            Types::JiraImportType,
            null: true,
            description: 'The Jira import data after mutation'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project to import the Jira project into'
      argument :jira_project_key, GraphQL::STRING_TYPE,
               required: true,
               description: 'Project key of the importer Jira project'
      argument :jira_project_name, GraphQL::STRING_TYPE,
               required: false,
               description: 'Project name of the importer Jira project'

      def resolve(project_path:, jira_project_key:)
        project = find_project!(project_path: project_path)

        raise_resource_not_available_error! unless project || Feature.enabled?(:jira_issue_import, project)

        service_response = ::JiraImport::StartImportService
                             .new(context[:current_user], project, jira_project_key)
                             .execute
        import_data = service_response.payload[:import_data]

        {
          jira_import: import_data.errors.blank? ? import_data.projects.last : nil,
          errors: errors_on_object(import_data)
        }
      end

      private

      def find_project!(project_path:)
        return unless project_path.present?

        authorized_find!(full_path: project_path)
      end

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end

      def authorized_resource?(project)
        Ability.allowed?(context[:current_user], :admin_project, project)
      end
    end
  end
end
