module Gitlab
  module Database
    # This class builds efficient distinct query by using loose index scan.
    # Consider the following example:
    # > Issue.distinct(:project_id).where(project_id: (1...100)).count
    #
    # Note: there is an index on project_id
    #
    # This query will read each element in the index matching the project_id filter.
    # If a project has 100_000 associated issues, all 100_000 elements will be read.
    #
    # A loose index scan will read only one entry from the index for each project_id to reduce the number of disk reads.
    #
    # Usage:
    #
    # Gitlab::Database::DistinctCount.new(Issue, :project_id).execute(from: 1, to: 100).count
    class DistinctCount
      def initialize(scope, column)
        @scope = scope
        @column = transform_column(column)
        @model = scope.try(:model) || scope
      end

      def count(from:, to:)
        build_query(from: from, to: to).count(column)
      end

      def build_query(from:, to:)
        cte = Gitlab::SQL::RecursiveCTE.new(:counter_cte, union_args: { remove_order: false })
        table = @model.arel_table

        cte << @scope.dup.select(table[column].as(column.to_s)).where(table[column].gteq(from)).where(table[column].lt(to)).order(column).limit(1)
        inner_query = @scope
          .dup
          .where(table[column].gt(cte.table[column]))
          .where(table[column].lt(to))
          .select(table[column])
          .order(column)
          .limit(1)

        cte << cte.table.project(Arel::Nodes::Grouping.new(Arel.sql(inner_query.to_sql)).as(column.to_s)).where(cte.table[column].lt(to))

        @model
          .with
          .recursive(cte.to_arel)
          .from(cte.alias_to(table))
          .unscope(where: :type)
      end

      private

      attr_reader :column

      # Transforms the column so it can be used in Arel expressions
      #
      # 'table.column' => 'column'
      # 'columnt' => 'column'
      # :column => :column
      # Arel::Attributes::Attribute => name of the column
      def transform_column(column)
        if column.is_a?(String) || column.is_a?(Symbol)
          column.to_s.include?(".") ? column.to_s.split('.').last : column
        elsif column.is_a?(Arel::Attributes::Attribute)
          column.name
        else
          raise "Cannot transform the column: #{column.inspect}, please provide the column name as string"
        end
      end
    end
  end
end
