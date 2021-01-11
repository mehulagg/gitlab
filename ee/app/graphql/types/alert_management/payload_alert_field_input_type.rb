# frozen_string_literal: true

module Types
  module AlertManagement
    class PayloadAlertFieldInputType < BaseInputObject
      graphql_name 'AlertManagementPayloadAlertFieldInput'
      description 'Field that are available while modifying the custom mapping attributes for an HTTP integration'

      argument :field_name,
                GraphQL::STRING_TYPE,
                required: true,
                description: 'An GitLab alert field name.'

      argument :path,
               [GraphQL::STRING_TYPE],
               required: true,
               description: 'Path to value inside payload JSON.'

      argument :label,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'Human-readble label of the payload path.'

      argument :type,
               GraphQL::STRING_TYPE,
               required: true,
               description: 'Type of the parsed value.'
    end
  end
end
