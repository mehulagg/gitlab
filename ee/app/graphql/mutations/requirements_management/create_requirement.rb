# frozen_string_literal: true

module Mutations
  module RequirementsManagement
    class CreateRequirement < BaseRequirement
      graphql_name 'CreateRequirement'

      authorize :create_requirement

      def resolve(args)
        project_path = args.delete(:project_path)
        project = authorized_find!(full_path: project_path)
        validate_flag!(project)

        requirement = ::RequirementsManagement::CreateRequirementService.new(
          project,
          context[:current_user],
          args
        ).execute

        {
          requirement: requirement.valid? ? requirement : nil,
          errors: errors_on_object(requirement)
        }
      end

      private

      def validate_flag!(project)
        return if ::Feature.enabled?(:requirements_management, project, default_enabled: true)

        raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'requirements_management flag is not enabled on this project'
      end

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end
