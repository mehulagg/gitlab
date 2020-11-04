# frozen_string_literal: true

module Types
  module AlertManagement
    class PayloadAlertFieldType < BaseObject
      graphql_name 'PayloadAlertFieldType'
      description 'Parsed fields from an alert used for custom mappings'

      authorize :read_alert_management_alert

      field :path,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Path to value inside payload JSON'

      field :label,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Human-readble label of the payload path'

      field :type,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Type of the parsed value'
    end
  end
end
