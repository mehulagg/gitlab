# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class ProjectCreateService < ::BaseProjectService
      def execute
        return if project.security_orchestration_policy_configuration.present?

        policy_project = ::Projects::CreateService.new(current_user, create_project_params).execute

        project.create_security_orchestration_policy_configuration! do |p|
          p.security_policy_management_project_id = policy_project.id
        end

        policy_project.add_users(project.team.maintainers, ::Gitlab::Access::DEVELOPER)

        ServiceResponse.success(payload: { policy_project: policy_project })
      end

      private

      def create_project_params
        {
          initialize_with_readme: true,
          visibility_level: project.visibility_level,
          name: "#{project.name} - Security policy project",
          description: "This project is automatically generated to manage security policies for the project.",
          namespace_id: project.namespace.id
        }
      end

      def error(message)
        ServiceResponse.error(payload: { policy_project: policy_project_id }, message: message)
      end

      attr_reader :project
    end
  end
end
