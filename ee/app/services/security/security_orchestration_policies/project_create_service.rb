# frozen_string_literal: true

module Security
  module SecurityOrchestrationPolicies
    class ProjectCreateService < ::BaseProjectService
      def execute
        return error('Security Policy project already exists.') if project.security_orchestration_policy_configuration.present?

        policy_project = ::Projects::CreateService.new(current_user, create_project_params).execute

        if policy_project.saved?
          project.create_security_orchestration_policy_configuration! do |p|
            p.security_policy_management_project_id = policy_project.id
          end

          policy_project.add_users(project.team.maintainers, :developer)

          success(policy_project: policy_project)
        else
          error(policy_project.errors.full_messages.join(','))
        end
      end

      private

      def create_project_params
        {
          visibility_level: project.visibility_level,
          name: "#{project.name} - Security policy project",
          description: "This project is automatically generated to manage security policies for the project.",
          namespace_id: project.namespace.id,
          initialize_with_readme: false,
          container_registry_enabled: false,
          packages_enabled: false,
          requirements_enabled: false,
          builds_enabled: false,
          wiki_enabled: false,
          snippets_enabled: false
        }
      end

      attr_reader :project
    end
  end
end
