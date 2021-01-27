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

      argument :selected_fields, [GraphQL::STRING_TYPE],
               required: false,
               description: 'List of selected requirements fields to be exported.'

      def resolve(args)
        project_path = args.delete(:project_path)
        project = authorized_find!(project_path)
        validate_selected_fields!(args[:selected_fields])

        IssuableExportCsvWorker.perform_async(:requirement, current_user.id, project.id, args)

        {
          errors: []
        }
      end

      def validate_selected_fields!(fields)
        return unless fields

        invalid_fields = fields.select do |field|
          ::RequirementsManagement::ExportCsvService::PERMITTED_FIELDS
            .map(&:downcase).exclude?(field.downcase)
        end

        if invalid_fields.any?
          message = "The following fields are incorrect: #{invalid_fields.join(', ')}."\
            " See https://docs.gitlab.com/ee/user/project/requirements/#exported-csv-file-format"\
            " for permitted fields."
          raise Gitlab::Graphql::Errors::ArgumentError, message
        end
      end
    end
  end
end
