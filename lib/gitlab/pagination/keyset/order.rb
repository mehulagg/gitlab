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

        def build_conditions_recursively(current_column_definitions, values, before_or_after, skip_distinct = false)
          definitions = current_column_definitions.reverse

          omg = []

          already_processed_columns = []
          loop do
            current_column_definition, *rest = definitions

            value = values[current_column_definition.attribute_name]
            column_expression = current_column_definition.column_expression

            or_expressions = []

            if current_column_definition.distinct?
              or_expressions << if before_or_after == :after
                                  column_expression.lt(value)
                                else
                                  column_expression.gt(value)
                                end
            else
              unless value.blank?
                or_expressions << if before_or_after == :after
                                    column_expression.lt(value)
                                  else
                                    column_expression.gt(value)
                                  end
              end
            end

            if current_column_definition.nullable? && current_column_definition.nulls_top?
              if value.blank?
                or_expressions << column_expression.not_eq(nil)
              end
            elsif current_column_definition.nullable? && current_column_definition.nulls_bottom?
              unless value.blank?
                or_expressions << column_expression.eq(nil)
              end
            end

            first_item = or_expressions.shift
            res = or_expressions.inject(first_item) do |previous_item, condition|
              Arel::Nodes::Or.new(previous_item, condition)
            end
            ors = Arel::Nodes::Grouping.new(res) if res

            xx = already_processed_columns.map do |c|
              if c.nullable? && values[c.attribute_name].present?
                c.column_expression.eq(nil)
              end

              if c.nullable? && values[c.attribute_name].blank?
                # c.column_expression.eq(nil)
                # c.column_expression.not_eq(nil)
              end
            end.compact

            # if values == {"year"=>nil, "month"=>nil, "id"=>"3"}
            # byebug
            # end

            final = Arel::Nodes::And.new([ors, *xx].compact)

            items = rest.map do |definition|
              v = values[definition.attribute_name]
              ce = definition.column_expression

              ce.eq(v)
            end

            if final.children.any?
              ands = [final, *items].compact
              omg << if ands.size == 1
                       ands.first
                     else
                       Arel::Nodes::Grouping.new(Arel::Nodes::And.new(ands))
                     end
            end

            definitions = rest
            break if definitions.empty?

            already_processed_columns << current_column_definition
          end

          first_or = omg.shift
          rr = omg.inject(first_or) do |previous_item, condition|
            Arel::Nodes::Or.new(previous_item, condition)
          end

          Arel::Nodes::Grouping.new(rr)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def apply_cursor_conditions(scope, values, before_or_after)
          scope.where(build_conditions_recursively(column_definitions, values, before_or_after))
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def reversed_order
          self.class.build(column_definitions.map(&:reverse))
        end

        private

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
