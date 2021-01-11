# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class Order < Arel::Nodes::SqlLiteral
        attr_reader :column_definitions
        def initialize(column_definitions:)
          @column_definitions = column_definitions
          super(to_sql_literal(@column_definitions))
        end

        def self.keyset_aware?(scope)
          scope.order_values.first.is_a?(self) &&
            scope.order_values.size == 1
        end

        def self.extract_keyset_order_object(scope)
          scope.order_values.first
        end

        def self.build(column_definitions)
          new(column_definitions: column_definitions)
        end

        def cursor_attributes_for_node(node)
          column_definitions.each_with_object({}) do |column_definition, hash|
            field_value = node[column_definition.attribute_name]
            hash[column_definition.attribute_name] = if field_value.is_a?(Time)
                                                       field_value.strftime('%Y-%m-%d %H:%M:%S.%N %Z')
                                                     elsif field_value.nil?
                                                       nil
                                                     else
                                                       field_value.to_s
                                                     end
          end
        end

        # TODO: more explanation and refactor
        def build_conditions_recursively(current_column_definitions, values)
          definitions = current_column_definitions.reverse

          where_values = []
          processed_columns = []

          loop do
            current_column_definition, *rest = definitions

            value = values[current_column_definition.attribute_name]
            column_expression = current_column_definition.column_expression

            column_or_expressions = []

            # Depending on the order, build a query condition fragment for taking the next rows
            if current_column_definition.distinct? || (!current_column_definition.distinct? && value.present?)
              column_or_expressions << compare_column_with_value(current_column_definition, value)
            end

            # When the column is nullable, additional conditions for NULL a NOT NULL values are necessary.
            # This depends on the position of the nulls (top or bottom of the resultset).
            if current_column_definition.nullable? && current_column_definition.nulls_top? && value.blank?
              column_or_expressions << column_expression.not_eq(nil)
            elsif current_column_definition.nullable? && current_column_definition.nulls_bottom? && value.present?
              column_or_expressions << column_expression.eq(nil)
            end

            column_or_expression = build_or_query(column_or_expressions)

            equal_conditon_for_rest = rest.map do |definition|
              definition.column_expression.eq(values[definition.attribute_name])
            end

            if column_or_expression.present?
              ands = [column_or_expression, *equal_conditon_for_rest].compact
              where_values << (ands.one? ? ands.first : Arel::Nodes::Grouping.new(Arel::Nodes::And.new(ands)))
            end

            definitions = rest
            break if definitions.empty?

            processed_columns << current_column_definition
          end

          build_or_query(where_values)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def apply_cursor_conditions(scope, values)
          scope.where(build_conditions_recursively(column_definitions, values))
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def reversed_order
          self.class.build(column_definitions.map(&:reverse))
        end

        private

        def compare_column_with_value(column_definition, value)
          if column_definition.descending_order?
            column_definition.column_expression.lt(value)
          else
            column_definition.column_expression.gt(value)
          end
        end

        def build_or_query(expressions)
          first_item = expressions.shift
          or_expression = expressions.inject(first_item) do |previous_item, condition|
            Arel::Nodes::Or.new(previous_item, condition)
          end

          Arel::Nodes::Grouping.new(or_expression) if or_expression
        end

        def to_sql_literal(column_definitions)
          column_definitions.map do |column_definition|
            if column_definition.order_expression.respond_to?(:to_sql)
              column_definition.order_expression.to_sql
            else
              column_definition.order_expression.to_s
            end
          end.join(', ')
        end
      end
    end
  end
end
