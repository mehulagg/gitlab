# frozen_string_literal: true

module EE
  module Issuable
    module Clone
      module AttributesRewriter
        def initialize(current_user, original_entity, new_entity)
          @current_user = current_user
          @original_entity = original_entity
          @new_entity = new_entity
        end

        extend ::Gitlab::Utils::Override
        def execute
          super

          copy_resource_weight_events
        end

        private

        def copy_resource_weight_events
          return unless both_respond_to?(:resource_weight_events)

          copy_events(ResourceWeightEvent.table_name, original_entity.resource_weight_events) do |event|
            event.attributes
              .except('id', 'reference', 'reference_html')
              .merge('issue_id' => new_entity.id)
          end
        end
      end
    end
  end
end
