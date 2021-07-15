# frozen_string_literal: true

module Mutations
  module Projects
    class SetComplianceFramework < BaseMutation
      graphql_name 'ProjectSetComplianceFramework'

      authorize :admin_compliance_framework

      argument :project_id, Types::GlobalIDType[::Project],
               required: true,
               description: 'ID of the project to change compliance framework.'

      argument :compliance_framework_id, Types::GlobalIDType[::ComplianceManagement::Framework],
               required: false,
               description: 'ID of the compliance framework to assign to the project.'

      field :project,
            Types::ProjectType,
            null: false,
            description: "The project after mutation."

      def resolve(project_id:, compliance_framework_id:)
        project = GitlabSchema.find_by_gid(project_id).sync

        authorize!(project)

        ::Projects::UpdateService.new(project, current_user, compliance_framework_setting_attributes: {
          framework: GitlabSchema.find_by_gid(compliance_framework_id).sync&.id || nil
        }).execute

        { project: project, errors: errors_on_object(project) }
      end
    end
  end
end
