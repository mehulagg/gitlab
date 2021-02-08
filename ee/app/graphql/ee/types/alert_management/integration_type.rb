# frozen_string_literal: true

module EE
  module Types
    module AlertManagement
      module IntegrationType
        extend ActiveSupport::Concern

        prepended do
          field :payload_example, ::Types::JsonStringType,
                null: true,
                description: 'The example of an alert payload.'

          field :payload_attribute_mappings, [::Types::AlertManagement::PayloadAlertFieldInputType],
                null: true,
                description: 'The custom mapping of GitLab alert attributes to fields from the payload_example.'
        end
      end
    end
  end
end
