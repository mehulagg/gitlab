# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class Iterator
        def initialize(scope:)
          @scope = scope
          @order = Gitlab::Pagination::Keyset::Order.extract_keyset_order_object(scope)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def each_batch(of: 1000)
          where_conditions = nil

          loop do
            records = scope.dup.where(where_conditions).reorder(order).limit(of).to_a

            break if records.empty?

            cursor_attributes = order.cursor_attributes_for_node(records.last)
            where_conditions = order.build_conditions_recursively(order.column_definitions, cursor_attributes)

            yield records
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        attr_reader :scope, :order
      end
    end
  end
end
