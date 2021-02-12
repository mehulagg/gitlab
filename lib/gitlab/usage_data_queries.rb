# frozen_string_literal: true

module Gitlab
  # This class is used by the `gitlab:usage_data:dump_sql` rake tasks to output SQL instead of running it.
  # See https://gitlab.com/gitlab-org/gitlab/-/merge_requests/41091
  class UsageDataQueries < UsageData
    class << self
      def count(relation, column = nil, *rest)
        raw_sql(relation, column)
      end

      def distinct_count(relation, column = nil, *rest)
        raw_sql(relation, column, :distinct)
      end

      def redis_usage_data(counter = nil, &block)
        if block_given?
          { redis_usage_data_block: block.to_s }
        elsif counter.present?
          { redis_usage_data_counter: counter }
        end
      end

      def sum(relation, column, *rest)
        relation.select(relation.all.table[column].sum).to_sql
      end

      # For estimated distinct count use exact query instead of hll
      # buckets query, because it can't be used to obtain estimations without
      # supplementary ruby code present in Gitlab::Database::PostgresHll::BatchDistinctCounter
      def estimate_batch_distinct_count(relation, column = nil, *rest)
        raw_sql(relation, column, :distinct)
      end

      private

      def raw_sql(relation, column, distinct = nil)
        column ||= relation.primary_key
        relation.select(relation.all.table[column].count(distinct)).to_sql
      end

      def collect_metric_name(relation)
        # ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
        collector = Arel::Collectors::SubstituteBinds.new(relation.model.connection, Arel::Collectors::SQLString.new)
        ProductIntelligenceVisitor.new(relation.model.connection).compile(relation.arel.ast, collector)
      end

      class ProductIntelligenceVisitor < Arel::Visitors::PostgreSQL
        def visit_Arel_Nodes_DeleteStatement(o, collector)
          raise NotImplementedError
        end
        alias_method :visit_Arel_Nodes_DeleteStatement, :visit_Arel_Nodes_UpdateStatement
        alias_method :visit_Arel_Nodes_DeleteStatement, :visit_Arel_Nodes_InsertStatement

        def visit_Arel_Nodes_SelectCore(o, collector)
          collect_nodes_for o.projections, collector, "", "_"

          collect_nodes_for o.wheres, collector, "_from_", "_"

          if o.source && !o.source.empty?
            collector << "_"
            collector = visit o.source, collector
          end

          maybe_visit o.comment, collector
        end

        def visit_Arel_Nodes_In(o, collector)
          unless Array === o.right
            return collect_in_clause(o.left, o.right, collector)
          end

          unless o.right.empty?
            o.right.delete_if { |value| unboundable?(value) }
          end

          raise StandardError, "malformed query: #{collector.value}" if o.right.empty?

          in_clause_length = @connection.in_clause_length

          if !in_clause_length || o.right.length <= in_clause_length
            collect_in_clause(o.left, o.right, collector)
          else
            o.right.each_slice(in_clause_length).each_with_index do |right, i|
              collector << " OR " unless i == 0
              collect_in_clause(o.left, right, collector)
            end
          end
        end

        def collect_in_clause(left, right, collector)
          collector =  visit(right, collector)
          collector << "_"
          visit left, collector
        end

        def visit_Arel_Nodes_And(o, collector)
          inject_join o.children, collector, "_and_"
        end

        def visit_Arel_Nodes_Equality(o, collector)
          right = o.right

          raise StandardError, "malformed query: #{collector.value}" if unboundable?(right)

          collector = visit o.left, collector

          if right.nil?
            collector << " IS NULL"
          else
            collector << "_"
            visit right, collector
          end
        end

        def visit_Arel_Nodes_IsNotDistinctFrom(o, collector)
          if o.right.nil?
            collector = visit o.left, collector
            collector << " IS NULL"
          else
            collector = is_distinct_from(o, collector)
            collector << " = 0"
          end
        end

        def visit_Arel_Nodes_IsDistinctFrom(o, collector)
          if o.right.nil?
            collector = visit o.left, collector
            collector << " IS NOT NULL"
          else
            collector = is_distinct_from(o, collector)
            collector << " = 1"
          end
        end

        def visit_Arel_Nodes_NotEqual(o, collector)
          right = o.right

          return collector << "1=1" if unboundable?(right)

          collector = visit o.left, collector

          if right.nil?
            collector << " IS NOT NULL"
          else
            collector << " != "
            visit right, collector
          end
        end

        def visit_Arel_Nodes_Count(o, collector)
          aggregate "count", o, collector
        end

        def visit_Arel_Nodes_Sum(o, collector)
          aggregate "sum", o, collector
        end

        def visit_Arel_Nodes_Max(o, collector)
          aggregate "max", o, collector
        end

        def visit_Arel_Nodes_Min(o, collector)
          aggregate "min", o, collector
        end

        def visit_Arel_Nodes_Avg(o, collector)
          aggregate "avg", o, collector
        end

        def visit_Arel_SelectManager(o, collector)
          visit(o.ast, collector)
        end

        def aggregate(name, o, collector)
          collector << "#{name}_"
          if o.distinct
            collector << "distinct_"
          end
          inject_join(o.expressions, collector, "_")
        end

        def quote(value)
          value
        end

        def quote_table_name(name)
          name
        end

        def quote_column_name(name)
          name
        end
      end
    end
  end
end

