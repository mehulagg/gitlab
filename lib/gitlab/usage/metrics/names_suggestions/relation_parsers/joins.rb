# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module NamesSuggestions
        module RelationParsers
          class Joins < ::Arel::Visitors::PostgreSQL
            def accept(object)
              object.source.right.map do |join|
                collector = Arel::Collectors::SubstituteBinds.new(@connection, Arel::Collectors::SQLString.new)
                visit(join, collector)
              end
            end

            # rubocop:disable Naming/MethodName
            # rubocop:enable Naming/MethodName

            def quote(value)
              "#{value}"
            end

            def quote_table_name(name)
              "#{name}"
            end

            def quote_column_name(name)
              "#{name}"
            end


            def inject_join(list, collector)
              list.map do |x|
               visit(x, collector)
              end
            end

            def visit_Arel_Nodes_StringJoin(o, collector)
              visit o.left, collector
            end

            def visit_Arel_Nodes_FullOuterJoin(o, collector)
              collector = visit o.left, collector
              collector << " "
              visit o.right, collector
            end

            def visit_Arel_Nodes_OuterJoin(o, collector)
              collector = visit o.left, collector
              collector << " "
              visit o.right, collector
            end

            def visit_Arel_Nodes_RightOuterJoin(o, collector)
              collector = visit o.left, collector
              collector << " "
              visit o.right, collector
            end

            def visit_Arel_Nodes_InnerJoin(o, collector)
              collector = visit o.left, collector
              if o.right
                collector << " "
                visit(o.right, collector)
              else
                collector
              end
            end

            def visit_Arel_Nodes_On(o, collector)
              collector << "ON "
              visit o.expr, collector
            end


            def operation_aggregate(_, o, collector)
              collector = inject_join(o.expressions, collector, ", ")
              if o.alias
                collector << " AS "
                visit o.alias, collector
              else
                collector
              end
            end
          end
        end
      end
    end
  end
end
