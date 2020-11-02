# frozen_string_literal: true

module EE
  module API
    module Helpers
      module ResourceLabelEventsHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :eventable_types
          def eventable_types
            [::Epic, *super]
          end
        end
      end
    end
  end
end
