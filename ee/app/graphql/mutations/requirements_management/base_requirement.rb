# frozen_string_literal: true

module Mutations
  module RequirementsManagement
    class BaseRequirement < BaseMutation
      include ResolvesProject

      field :requirement, Types::RequirementsManagement::RequirementType,
            null: true,
            description: 'The requirement after mutation'

      argument :title, GraphQL::STRING_TYPE,
               required: false,
               description: 'Title of the requirement'

      argument :description, GraphQL::STRING_TYPE,
               required: false,
               description: 'The description of the requirement'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project full path the requirement is associated with'
    end
  end
end
