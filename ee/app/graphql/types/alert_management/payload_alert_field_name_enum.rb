# frozen_string_literal: true

module Types
  module AlertManagement
    class PayloadAlertFieldNameEnum < BaseEnum
      graphql_name 'AlertManagementPayloadAlertFieldName'
      description 'Values for alert field names used in the custom mapping'

      ::Gitlab::AlertManagement.custom_mapping_data.each do |field_name, params|
        value field_name.to_s.upcase, params[:description], value: field_name.to_s
      end
    end
  end
end
