# frozen_string_literal: true

module Mutations
  module ComplianceManagement
    module Frameworks
      class Update < ::Mutations::BaseMutation
        graphql_name 'UpdateComplianceFramework'

        authorize :manage_compliance_framework

        argument :id,
                 ::Types::GlobalIDType[::ComplianceManagement::Framework],
                 required: true,
                 description: 'The global ID of the compliance framework to update'

        argument :name,
                 GraphQL::STRING_TYPE,
                 required: false,
                 description: 'New name for the compliance framework'

        argument :description,
                 GraphQL::STRING_TYPE,
                 required: false,
                 description: 'New description for the compliance framework'

        argument :color,
                 GraphQL::STRING_TYPE,
                 required: false,
                 description: 'New color representation of the compliance framework in hex format. e.g. #FCA121'

        field :compliance_framework,
              Types::ComplianceManagement::ComplianceFrameworkType,
              null: true,
              description: "The compliance framework after mutation"

        def resolve(id:, **args)
          framework = authorized_find!(id: id)
          ::ComplianceManagement::Frameworks::UpdateService.new(framework: framework,
                                                                current_user: current_user,
                                                                params: args).execute
          { compliance_framework: framework, errors: errors_on_object(framework) }
        end

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::ComplianceManagement::Framework)
        end
      end
    end
  end
end
