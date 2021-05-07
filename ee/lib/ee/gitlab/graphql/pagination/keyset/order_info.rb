# frozen_string_literal: true

module EE
  module Gitlab
    module Graphql
      module Pagination
        module Keyset
          module OrderInfo
            extend ::Gitlab::Utils::Override

            private

            override :extract_attribute_values
            def extract_attribute_values(order_value)
              if ordering_by_excess_storage?(order_value)
                ['excess_storage', order_value.direction, order_value.expr]
              else
                super
              end
            end

            # determine if ordering using STORAGE
            def ordering_by_excess_storage?(order_value)
              order_value.expr.is_a?(Arel::Nodes::Grouping) &&
                order_value.to_sql.delete('"').include?('(project_statistics.repository_size + project_statistics.lfs_objects_size)')
            end
          end
        end
      end
    end
  end
end
