# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class ColumnOrderDefinition
        attr_reader :attribute_name, :column_expression, :order_expression, :reversed_order_expression, :nullable, :distinct
        def initialize(attribute_name:, column_expression: nil, order_expression:, reversed_order_expression: nil, nullable:, distinct:)
          @attribute_name = attribute_name
          @column_expression = column_expression
          @order_expression = order_expression
          @reversed_order_expression = reversed_order_expression || calculate_reversed_order(order_expression)
          @nullable = nullable
          @distinct = distinct
        end

        def nullable?
          @nullable
        end

        def distinct?
          @distinct
        end

        def reverse
          self.class.new(
            attribute_name: attribute_name,
            column_expression: column_expression,
            order_expression: reversed_order_expression,
            reversed_order_expression: order_expression,
            nullable: nullable.present? ? { nulls_position: null_positions[nullable[:nulls_position]] } : false,
            distinct: distinct
          )
        end

        def null_positions
          {
            top: :bottom,
            bottom: :top
          }
        end

        def nulls_top?
          @nullable.is_a?(Hash) && @nullable[:nulls_position] == :top
        end

        def nulls_bottom?
          @nullable.is_a?(Hash) && @nullable[:nulls_position] == :bottom
        end

        private

        def calculate_reversed_order(order_expression)
          if order_expression.is_a?(Arel::Nodes::Ascending) || order_expression.is_a?(Arel::Nodes::Descending) # Arel can reverse simple orders
            order_expression.reverse
          else
            raise "Couldn't calculate the reverse order for `#{order_expression}`, please provide the `reversed_order_expression` parameter."
          end
        end
      end
    end
  end
end
