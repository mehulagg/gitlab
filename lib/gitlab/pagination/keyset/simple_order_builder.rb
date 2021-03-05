# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class SimpleOrderBuilder
        def self.build(scope)
          new(scope: scope).build
        end

        def initialize(scope:)
          @scope = scope
          @order_values = scope.order_values
          @model_class = scope.model
          @arel_table = @model_class.arel_table
          @primary_key = @model_class.primary_key
        end

        def build
          order = if order_values.empty?
                    primary_key_ascending_order
                  elsif ordered_by_primary_key?
                    primary_key_order
                  elsif ordered_by_other_column?
                    column_with_tie_breaker_order
                  elsif ordered_by_other_column_with_tie_breaker?
                    tie_breaker_attribute = order_values.second

                    tie_breaker_column_order = Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
                      attribute_name: model_class.primary_key,
                      order_expression: tie_breaker_attribute
                    )

                    column_with_tie_breaker_order(tie_breaker_column_order)
                  end

          order ? scope.reorder!(order) : :unable_to_order
        end

        private

        attr_reader :scope, :order_values, :model_class, :arel_table, :primary_key

        def primary_key_ascending_order
          Gitlab::Pagination::Keyset::Order.build([
            Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
              attribute_name: model_class.primary_key,
              order_expression: arel_table[primary_key].asc
            )
          ])
        end

        def primary_key_order
          Gitlab::Pagination::Keyset::Order.build([
            Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
              attribute_name: model_class.primary_key,
              order_expression: order_values.first
            )
          ])
        end

        def column_with_tie_breaker_order(tie_breaker_column_order = default_tie_breaker_column_order)
          order_expression = order_values.first
          attrbute_name = order_expression.expr.name

          column_nullable = model_class.columns.find { |column| column.name == attrbute_name }.null

          nullable = if column_nullable && order_expression.is_a?(Arel::Nodes::Ascending)
                       :nulls_last
                     elsif column_nullable && order_expression.is_a?(Arel::Nodes::Descending)
                       :nulls_first
                     else
                       :not_nullable
                     end

          Gitlab::Pagination::Keyset::Order.build([
            Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
              attribute_name: order_expression.expr.name,
              order_expression: order_expression,
              nullable: nullable,
              distinct: false
            ),
            tie_breaker_column_order
          ])
        end

        def ordered_by_primary_key?
          return unless order_values.one?

          attribute = order_values.first.try(:expr)

          return unless attribute

          arel_table[primary_key.to_s] == attribute || arel_table[primary_key.to_sym] == attribute
        end

        def ordered_by_other_column?
          return unless order_values.one?

          attribute = order_values.first.try(:expr)

          return unless attribute

          model_class.column_names.include?(attribute.name.to_s)
        end

        def ordered_by_other_column_with_tie_breaker?
          return unless order_values.size == 2

          attribute = order_values.first.try(:expr)
          tie_breaker_attribute = order_values.second.try(:expr)

          return unless attribute
          return unless tie_breaker_attribute

          model_class.column_names.include?(attribute.name.to_s) &&
            arel_table[primary_key.to_s] == tie_breaker_attribute || arel_table[primary_key.to_sym] == tie_breaker_attribute
        end

        def default_tie_breaker_column_order
          Gitlab::Pagination::Keyset::ColumnOrderDefinition.new(
            attribute_name: model_class.primary_key,
            order_expression: arel_table[primary_key].desc
          )
        end
      end
    end
  end
end
