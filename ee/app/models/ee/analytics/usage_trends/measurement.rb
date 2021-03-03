# frozen_string_literal: true

module EE
  module Analytics
    module UsageTrends
      # Measurement EE mixin
      #
      # This module is intended to encapsulate EE-specific model logic
      # and be prepended in the `Measurement` model
      module Measurement
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :identifier_query_mapping
          def identifier_query_mapping
            super.merge(
              {
                identifiers[:billable_users] => -> { ::User.billable }
              }
            )
          end

          override :identifier_min_max_queries
          def identifier_min_max_queries
            super.merge(
              {
                identifiers[:billable_users] => {
                  minimum_query: -> { ::User.minimum(:id) },
                  maximum_query: -> { ::User.maximum(:id) }
                }
              }
            )
          end
        end
      end
    end
  end
end
