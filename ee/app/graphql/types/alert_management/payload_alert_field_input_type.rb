# frozen_string_literal: true

module Types
  module AlertManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class PayloadAlertFieldInputType < BaseInputObject
      graphql_name 'AlertManagementPayloadAlertFieldInput'
      description 'Field that are available while modifying the custom mapping attributes for an HTTP integration'

      argument :field_name,
                ::Types::AlertManagement::PayloadAlertFieldNameEnum,
                required: true,
                description: 'A GitLab alert field name.'

      argument :path,
               [GraphQL::STRING_TYPE],
               required: true,
               description: 'Path to value inside payload JSON.'

      argument :label,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'Human-readable label of the payload path.'

      argument :type,
               ::Types::AlertManagement::PayloadAlertFieldTypeEnum,
               required: true,
               description: 'Type of the parsed value.'
    end
  end
end
