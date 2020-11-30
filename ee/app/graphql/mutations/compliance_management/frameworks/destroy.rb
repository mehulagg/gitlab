# frozen_string_literal: true

module Mutations
  module ComplianceManagement
    module Frameworks
      class Destroy < ::Mutations::BaseMutation
        graphql_name 'DestroyComplianceFramework'

        argument :id,
                 ::Types::GlobalIDType[::ComplianceManagement::Framework],
                 required: true,
                 description: 'The global ID of the compliance framework to destroy'

        def resolve(id:)
          service = ::ComplianceManagement::Frameworks::DestroyService.new(framework: framework(id), current_user: current_user)

          service.execute
        end

        private

        def framework(gid)
          GlobalID::Locator.locate gid
        end
      end
    end
  end
end
