# frozen_string_literal: true

module Mutations
  module ComplianceManagement
    module Frameworks
      class Create < BaseMutation

        graphql_name 'CreateComplianceFramework'

        # authorize

        field :framework,
              Types::ComplianceManagement::ComplianceFrameworkType,
              null: true,
              description: 'The created compliance framework'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'Name of the compliance framework'

        def resolve(name:)
          {
            framework: ::ComplianceManagement::Framework.new,
            errors: {}
          }
        end
      end
    end
  end
end
