# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class ColumnOrderDefinition
        REVERSED_ORDER_DIRECTIONS = { asc: :desc, desc: :asc }.freeze
        REVERSED_NULL_POSITIONS = { top: :bottom, bottom: :top }.freeze

        attr_reader :attribute_name, :column_expression, :order_expression, :reversed_order_expression, :nullable, :distinct, :order_direction

        alias_method :nullable?, :nullable
        alias_method :distinct?, :distinct

        def initialize(attribute_name:, column_expression: nil, order_expression:, reversed_order_expression: nil, nullable:, distinct:, order_direction: :asc)
          @attribute_name = attribute_name
          @column_expression = column_expression
          @order_expression = order_expression
          @reversed_order_expression = reversed_order_expression || calculate_reversed_order(order_expression)
          @nullable = nullable
          @distinct = distinct
          @order_direction = parse_order_direction(order_direction)
        end

        def reverse
          self.class.new(
            attribute_name: attribute_name,
            column_expression: column_expression,
            order_expression: reversed_order_expression,
            reversed_order_expression: order_expression,
            nullable: nullable.present? ? { nulls_position: REVERSED_NULL_POSITIONS[nullable[:nulls_position]] } : false,
            distinct: distinct,
            order_direction: REVERSED_ORDER_DIRECTIONS[order_direction]
          )
        end

        def ascending_order?
          order_direction == :asc
        end

        def descending_order?
          order_direction == :desc
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

        def parse_order_direction(order_direction)
          transformed_order_direction = order_direction.to_s.downcase.to_sym

          unless REVERSED_ORDER_DIRECTIONS.has_key?(transformed_order_direction)
            raise "Invalid `order_direction` (`#{order_direction}`) is given, the allowed values are: :asc or :desc"
          end

          transformed_order_direction
        end
      end
    end
  end
end
