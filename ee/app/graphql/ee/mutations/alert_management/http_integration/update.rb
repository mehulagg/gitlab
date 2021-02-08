# frozen_string_literal: true

module EE
  module Mutations
    module AlertManagement
      module HttpIntegration
        module Update
          extend ActiveSupport::Concern

          prepended do
            argument :payload_example, ::Types::JsonStringType,
                     required: false,
                     description: 'The example of an alert payload.'

            argument :payload_attribute_mappings, [::Types::AlertManagement::PayloadAlertFieldInputType],
                     required: false,
                     description: 'The custom mapping of GitLab alert attributes to fields from the payload_example.'
          end
        end
      end
    end
  end
end
