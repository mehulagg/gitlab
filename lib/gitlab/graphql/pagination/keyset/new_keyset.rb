module Gitlab
  module Graphql
    module Pagination
      module Keyset
        module NewKeyset 
          extend ActiveSupport::Concern

          def ordered_items
            if Gitlab::Pagination::Keyset::Order.keyset_aware?(items)
              items
            else
              super
            end
          end

          def cursor_for(node)
            if Gitlab::Pagination::Keyset::Order.keyset_aware?(items)
              order = items.order_values.first
              encode(order.cursor_attributes_for_node(node).to_json)
            else
              super
            end
          end

          def slice_nodes(sliced, encoded_cursor, before_or_after)
            if Gitlab::Pagination::Keyset::Order.keyset_aware?(items)
              order = items.order_values.first

              decoded_cursor = ordering_from_encoded_json(encoded_cursor)
              order.apply_cursor_conditions(items, decoded_cursor, before_or_after)
            else
              super
            end
          end

          def sliced_nodes
            if Gitlab::Pagination::Keyset::Order.keyset_aware?(items)
              sliced = ordered_items
              sliced = slice_nodes(sliced, before, :before) if before.present?
              sliced = slice_nodes(sliced, after, :after) if after.present?

              sliced
            else
              super
            end
          end
        end
      end
    end
  end
end

