# frozen_string_literal: true

module EE
  module Mutations
    module AlertManagement
      module HttpIntegration
        module Create
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            argument :payload_example, GraphQL::STRING_TYPE,
                     required: false,
                     description: 'The example of an alert payload.'

            argument :payload_attribute_mapping, GraphQL::STRING_TYPE,
                     required: false,
                     description: 'The custom mapping of an alert attributes.'
          end

          private

          override :http_integration_params
          def http_integration_params(args)
            base_args = super(args)
            project = authorized_find!(full_path: args[:project_path])

            return base_args unless ::Gitlab::AlertManagement.custom_mapping_available?(project)

            base_args.merge(
              payload_example: payload_example(args),
              payload_attribute_mapping: payload_attribute_mapping(args)
            )
          end

          def payload_example(args)
            ::Gitlab::Json.parse!(args[:payload_example])
          rescue JSON::ParseError
            {}
          end

          def payload_attribute_mapping(args)
            ::Gitlab::Json.parse!(args[:payload_attribute_mapping])
          rescue JSON::ParseError
            {}
          end
        end
      end
    end
  end
end
