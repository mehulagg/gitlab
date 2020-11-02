# frozen_string_literal: true

module EE
  module API
    module Helpers
      module DiscussionsHelpers
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :noteable_types
          def noteable_types
            [::Epic, *super]
          end
        end
      end
    end
  end
end
