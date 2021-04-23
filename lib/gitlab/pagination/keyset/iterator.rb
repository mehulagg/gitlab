# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class Iterator
        def initialize(scope:, use_union_optimization: false)
          @scope = scope
          @order = Gitlab::Pagination::Keyset::Order.extract_keyset_order_object(scope)
          @use_union_optimization = use_union_optimization
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def each_batch(of: 1000)
          cursor_attributes = {}

          loop do
            current_scope = scope.dup.limit(of)
            records = order
              .apply_cursor_conditions(current_scope, cursor_attributes, use_union_optimization: @use_union_optimization)
              .reorder(order)
              .limit(of)
              .to_a

            break if records.empty?

            yield records

            cursor_attributes = order.cursor_attributes_for_node(records.last)
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        attr_reader :scope, :order
      end
    end
  end
end
