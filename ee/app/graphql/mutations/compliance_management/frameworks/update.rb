# frozen_string_literal: true

module Mutations
  module ComplianceManagement
    module Frameworks
      class Update < ::Mutations::BaseMutation
        graphql_name 'UpdateComplianceFramework'

        argument :id,
                 ::Types::GlobalIDType[::ComplianceManagement::Framework],
                 required: true,
                 description: 'The global ID of the compliance framework to update'

        argument :name,
                 GraphQL::STRING_TYPE,
                 required: false,
                 description: 'New name for the compliance framework'

        field :compliance_framework,
              Types::ComplianceManagement::ComplianceFrameworkType,
              null: true,
              description: "The compliance framework after mutation"

        def resolve(id:, **args)
          framework = framework_by_gid(id)

          ::ComplianceManagement::Frameworks::UpdateService.new(framework: framework,
                                                                current_user: current_user,
                                                                params: args).execute
          { compliance_framework: framework, errors: errors_on_object(framework) }
        end

        private

        def framework_by_gid(gid)
          GlobalID::Locator.locate gid
        end
      end
    end
  end
end
