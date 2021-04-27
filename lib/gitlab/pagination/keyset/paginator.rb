# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class Paginator
        include Gitlab::Pagination::Keyset::Paginatable
        include Enumerable

        UnsupportedScopeOrder = Class.new(StandardError)

        attr_reader :order

        # scope                  - ActiveRecord::Relation object with order by clause
        # cursor                 - Encoded cursor attributes as String. Empty value will requests the first page.
        # per_page               - Number of items per page.
        # cursor_converter       - Object that serializes and de-serializes the cursor attributes. Implements dump and parse methods.
        # direction_key          - Symbol that will be the hash key of the direction within the cursor. (default: _kd => keyset direction)
        def initialize(scope:, cursor: nil, per_page: 20, cursor_converter: Base64CursorConverter, direction_key: :_kd)
          @keyset_scope = build_scope(scope)
          @order = Gitlab::Pagination::Keyset::Order.extract_keyset_order_object(@keyset_scope)

          setup_pagination_variables(cursor, per_page, cursor_converter, direction_key)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        override :records
        def records
          @records ||= begin
            items = if paginate_backward?
                      reversed_order
                        .apply_cursor_conditions(keyset_scope, cursor_attributes)
                        .reorder(reversed_order)
                        .limit(per_page_plus_one)
                        .to_a
                    else
                      order
                        .apply_cursor_conditions(keyset_scope, cursor_attributes)
                        .limit(per_page_plus_one)
                        .to_a
                    end

            state.has_another_page = items.size == per_page_plus_one
            items.pop if state.has_another_page
            items.reverse! if paginate_backward?
            items
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        delegate :reversed_order, to: :order

        def build_scope(scope)
          keyset_aware_scope, success = Gitlab::Pagination::Keyset::SimpleOrderBuilder.build(scope)

          raise(UnsupportedScopeOrder, 'The order on the scope does not support keyset pagination') unless success

          keyset_aware_scope
        end
      end
    end
  end
end
