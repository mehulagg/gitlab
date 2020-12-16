# frozen_string_literal: true

module Mutations
  module ComplianceManagement
    module Frameworks
      class Create < BaseMutation
        graphql_name 'CreateComplianceFramework'

        field :framework,
              Types::ComplianceManagement::ComplianceFrameworkType,
              null: true,
              description: 'The created compliance framework.'

        argument :namespace_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'Full path of the namespace to add the compliance framework to.'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'Name of the compliance framework.'

        argument :description, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'Description of the compliance framework.'

        argument :color, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'Color to represent the compliance framework as a hexadecimal value. e.g. #ABC123.'

        def resolve(**args)
          service = ::ComplianceManagement::Frameworks::CreateService.new(namespace: namespace(args[:namespace_path]),
                                                                          params: args,
                                                                          current_user: current_user).execute

          service.success? ? success(service) : error(service)
        end

        private

        def success(service)
          { framework: service.payload[:framework], errors: [] }
        end

        def error(service)
          errors = [service.message]
          model_errors = service.payload.try(:full_messages).to_a

          { errors: (errors + model_errors).flatten }
        end

        def namespace(namespace_path)
          ::Gitlab::Graphql::Loaders::FullPathModelLoader.new(Namespace, namespace_path).find.sync
        end
      end
    end
  end
end
