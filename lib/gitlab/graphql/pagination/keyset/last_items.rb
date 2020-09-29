# frozen_string_literal: true

module Gitlab
  module Graphql
    module Pagination
      module Keyset
        # This class handles the last(N) ActiveRecord call even if a special ORDER BY configuration is present.
        # For the last(N) call, ActiveRecord calls reverse_order, however for some cases it raises
        # ActiveRecord::IrreversibleOrderError error.
        class LastItems
          # rubocop: disable CodeReuse/ActiveRecord
          def self.take_items(scope, count)
            if custom_order = lookup_custom_reverse_order(scope.order_values)
              scope.reorder(*custom_order).first(count).reverse
            else
              scope.last(count)
            end
          end
          # rubocop: enable CodeReuse/ActiveRecord

          # Detect special ordering and provide the reversed order
          def self.lookup_custom_reverse_order(order_values)
            if ordering_by_merged_at_and_mr_id_desc?(order_values)
              [
                Gitlab::Database.nulls_first_order('merge_request_metrics.merged_at', 'ASC'),
                MergeRequest.arel_table[:id].desc
              ]
            elsif ordering_by_merged_at_and_mr_id_asc?(order_values)
              [
                Gitlab::Database.nulls_first_order('merge_request_metrics.merged_at', 'DESC'),
                MergeRequest.arel_table[:id].desc
              ]
            end
          end

          def self.ordering_by_merged_at_and_mr_id_desc?(order_values)
            order_values.size == 2 &&
              order_values.first.to_s == Gitlab::Database.nulls_last_order('merge_request_metrics.merged_at', 'DESC') &&
              order_values.last.is_a?(Arel::Nodes::Descending) &&
              order_values.last.to_sql == MergeRequest.arel_table[:id].desc.to_sql
          end

          def self.ordering_by_merged_at_and_mr_id_asc?(order_values)
            order_values.size == 2 &&
              order_values.first.to_s == Gitlab::Database.nulls_last_order('merge_request_metrics.merged_at', 'ASC') &&
              order_values.last.is_a?(Arel::Nodes::Ascending) &&
              order_values.last.to_sql == MergeRequest.arel_table[:id].asc.to_sql
          end
        end
      end
    end
  end
end
