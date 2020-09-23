# frozen_string_literal: true

module Mutations
  module DastScannerProfiles
    class Create < BaseMutation
      include AuthorizesProject

      graphql_name 'DastScannerProfileCreate'

      field :id, GraphQL::ID_TYPE,
            null: true,
            description: 'ID of the scanner profile.',
            deprecated: { reason: 'Use `global_id`', milestone: '13.4' }

      field :global_id, ::Types::GlobalIDType[::DastScannerProfile],
            null: true,
            description: 'ID of the scanner profile.'

      argument :full_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project the scanner profile belongs to.'

      argument :profile_name, GraphQL::STRING_TYPE,
                required: true,
                description: 'The name of the scanner profile.'

      argument :spider_timeout, GraphQL::INT_TYPE,
                required: false,
                description: 'The maximum number of minutes allowed for the spider to traverse the site.'

      argument :target_timeout, GraphQL::INT_TYPE,
                required: false,
                description: 'The maximum number of seconds allowed for the site under test to respond to a request.'

      authorize :create_on_demand_dast_scan

      def resolve(full_path:, profile_name:, spider_timeout: nil, target_timeout: nil)
        project = authorized_find_project!(full_path: full_path)

        service = ::DastScannerProfiles::CreateService.new(project, current_user)
        result = service.execute(name: profile_name, spider_timeout: spider_timeout, target_timeout: target_timeout)

        if result.success?
          { id: result.payload.to_global_id, global_id: result.payload.to_global_id, errors: [] }
        else
          { errors: result.errors }
        end
      end
    end
  end
end
