# frozen_string_literal: true

module Mutations
  module RequirementsManagement
    class CreateRequirement < BaseMutation
      include ResolvesProject

      graphql_name 'CreateRequirement'

      authorize :create_requirement

      field :requirement, Types::RequirementsManagement::RequirementType,
            null: true,
            description: 'The requirement after mutation'

      argument :title, GraphQL::STRING_TYPE,
               required: true,
               description: 'Title of the requirement'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project full path the requirement is associated with'

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
