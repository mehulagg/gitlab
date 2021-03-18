# frozen_string_literal: true

module Arel
  module Nodes
    class AsWithMaterialized < Arel::Nodes::Binary
      MATERIALIZED = Arel.sql(' MATERIALIZED')
      EMPTY_STRING = Arel.sql('')
      attr_reader :expr

      def initialize(left, right, materialized: true)
        @expr = if materialized && self.class.materialized_supported?
                  MATERIALIZED
                else
                  EMPTY_STRING
                end

        super(left, right)
      end

      # Note this method will be deleted after the minimum PG version is set to 12.0
      def self.materialized_supported?
        Gitlab::Database.version.match?(/^1[2-9]\./) # version 12.x and above
      end
    end
  end

  module Visitors
    class Arel::Visitors::ToSql
      def visit_Arel_Nodes_AsWithMaterialized(obj, collector) # rubocop:disable Naming/MethodName
        collector = visit o.left, collector
        collector << " AS#{obj.expr} "
        visit obj.right, collector
      end
    end
  end
end
