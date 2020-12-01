# frozen_string_literal: true

module Mutations
  module RequirementsManagement
    class CreateRequirement < BaseRequirement
      graphql_name 'CreateRequirement'

      authorize :create_requirement

      def resolve(args)
        project_path = args.delete(:project_path)
        project = authorized_find!(full_path: project_path)

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

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end
