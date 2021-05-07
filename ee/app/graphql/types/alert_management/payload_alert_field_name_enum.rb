# frozen_string_literal: true

module Types
  module AlertManagement
    class PayloadAlertFieldNameEnum < BaseEnum
      graphql_name 'AlertManagementPayloadAlertFieldName'
      description 'Values for alert field names used in the custom mapping'

      ::Gitlab::AlertManagement.alert_fields.each do |field|
        value field[:name].upcase, description: field[:description], value: field[:name]
      end
    end
  end
end
