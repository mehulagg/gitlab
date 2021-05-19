# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      class RecursiveUnionWithMultiIndexScan
        class ColumnData
          attr_reader :original_column_name, :as, :arel_table

          def initialize(original_column_name, as, arel_table)
            @original_column_name = original_column_name
            @as = as
            @arel_table = arel_table
          end

          def projection
            arel_column.as(as)
          end

          def arel_column
            arel_table[original_column_name]
          end

          def arel_column_as
            arel_table[as]
          end

          def array_aggregated_column_name
            "#{arel_table.name}_#{original_column_name}_array"
          end

          def array_aggregated_column
            Arel::Nodes::NamedFunction.new('ARRAY_AGG', [arel_column]).as(array_aggregated_column_name)
          end
        end

        def initialize(scope:, order:, array_scope:, array_mapping_scope:, finder_query:, values:)
          @scope = scope.dup
          @order = order
          @array_scope = array_scope
          @array_mapping_scope = array_mapping_scope
          @finder_query = finder_query
          @values = values
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def execute
          selector_cte = Gitlab::SQL::CTE.new(:array_cte, array_scope)

          cte = Gitlab::SQL::RecursiveCTE.new(recursive_cte_name, union_args: { remove_duplicates: false, remove_order: false })
          cte << initializer_query
          cte << collector_query

          q = cte
            .apply_to(scope.model.where({})
            .with(selector_cte.to_arel))
            .select("(records).*")
            .where("(records).id is not null")

          scope.model.from("(#{q.to_sql}) as #{table_name}")
        end
        # rubocop: enable CodeReuse/ActiveRecord

        private

        attr_reader :array_scope, :scope, :order, :array_mapping_scope, :finder_query

        def recursive_cte_name
          :recursive_keyset_cte
        end

        def array_scope_cte_name
          :array_cte
        end

        def table_name
          @table_name ||= scope.model.table_name
        end

        def arel_table
          @scope.model.arel_table
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def collector_query
          array_column_list = (array_scope_columns).map(&:array_aggregated_column_name).join(', ')

          arrays = order_by_columns.map do |column|
            name = "#{recursive_cte_name}.#{column.array_aggregated_column_name}"
            "#{name}[:position_query.position-1]||record_query.#{column.original_column_name}||#{name}[position_query.position+1:]"
          end

          select = """
          (#{record_finder_query}),
          #{array_column_list},
          #{arrays.join(',')},
          position
          """

          from = """
          #{recursive_cte_name},
          LATERAL (
            #{array_order_query}
          ) as position_query,
          LATERAL (
            SELECT #{order_by_columns.map(&:original_column_name).join(', ')} FROM (
              (#{next_record_finder_query})
              UNION ALL
              (SELECT #{order_by_columns.map { |_| 'null' }.join(', ')})
            ) as ensure_there_is_value LIMIT 1
          ) as record_query
          """

          Issue.select(select).from(from)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def array_order_query
          """
          SELECT #{order_by_columns.map(&:original_column_name).join(', ')}, position
          FROM UNNEST(#{order_by_columns.map(&:array_aggregated_column_name).join(', ')}) WITH
          ORDINALITY AS u(#{order_by_columns.map(&:original_column_name).join(', ')}, position)
          WHERE #{order_by_columns.map { |c| c.original_column_name + ' IS NOT NULL' }.join(' AND ')}
          ORDER BY #{order_by_without_table_references}
          LIMIT 1
          """
        end

        def next_record_finder_query
          cursor_values = order_by_columns.each_with_object({}) { |c, h| h[c.original_column_name] = Arel.sql("#{recursive_cte_name}.#{c.array_aggregated_column_name}[position]") }
          array_mapping_scope_columns = array_scope_columns.map { |c| Arel.sql("#{recursive_cte_name}.#{c.array_aggregated_column_name}[position]") }

          order
            .apply_cursor_conditions(scope.dup.reselect(*order_by_columns.map(&:arel_column)).merge(array_mapping_scope.call(*array_mapping_scope_columns)), cursor_values, use_union_optimization: true)
            .reselect(*order_by_columns.map(&:arel_column))
            .limit(1)
            .to_sql
        end

        def record_finder_query
          columns = order_by_columns.map do |column|
            Arel.sql("#{recursive_cte_name}.#{column.array_aggregated_column_name}[position]")
          end
          finder_query.call(*columns).select("#{table_name}").limit(1).to_sql
        end

        def order_by_without_table_references
          order.to_sql.gsub(/("\w+"\.)/, '')
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def initializer_query
          p = (array_scope_columns + order_by_columns).map(&:array_aggregated_column_name).join(', ')
          projections = [
            "NULL::#{table_name} as records",
            *p,
            "0::bigint as pos"
          ]
          Issue.select(projections).from(array_scope_lateral_query).limit(1)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def array_scope_table
          @array_scope_table ||= Arel::Table.new(array_scope_cte_name)
        end

        def array_scope_columns
          array_scope.select_values.map do |column_name|
            ColumnData.new(column_name, "array_scope_#{column_name}", array_scope_table)
          end
        end

        def order_by_columns
          order.column_definitions.map do |column_definition|
            ColumnData.new(column_definition.attribute_name, "order_by_columns_#{column_definition.attribute_name}", arel_table)
          end
        end

        def array_scope_lateral_query
          projections = (array_scope_columns + order_by_columns).map(&:array_aggregated_column).map(&:to_sql).join(', ')

          query = order
            .apply_cursor_conditions(scope.dup.merge(array_mapping_scope.call(*array_scope_columns.map(&:arel_column))), @values, use_union_optimization: true)
            .reselect(*order_by_columns.map(&:arel_column))
            .limit(1)
            .to_sql

          Arel.sql("""
          (
            SELECT #{projections}
            FROM (SELECT #{array_scope_columns.map(&:arel_column).map(&:name).join(', ')} FROM #{array_scope_cte_name}) as #{array_scope_cte_name}
            LEFT JOIN LATERAL (
              #{query}
            ) #{table_name} ON TRUE
            WHERE #{order_by_columns.map {|c| c.arel_column.not_eq(nil).to_sql}.join(" AND ")}
          )
          """).as('array_scope_lateral_query')
        end
      end
    end
  end
end
