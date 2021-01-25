# frozen_string_literal: true

module Gitlab
  module Graphql
    module QueryAnalyzers
      class ComplexityAnalyzer
        ANALYZER = GraphQL::Analysis::QueryComplexity.new { |_query, complexity| complexity }

        # def analyze?(query)
        #   Feature.enabled?(:graphql_query_analyzer, default_enabled: true)
        # end

        def initial_value(query)
          query
        end

        def call(memo, _visit_type, _irep_node)
          memo
        end

        def final_value(memo)
          return if memo.nil?

          complexity = GraphQL::Analysis.analyze_query(memo, [ANALYZER]).first

          RequestStore.store[:query_complexity] = complexity
        rescue => e
          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
        end
      end
    end
  end
end
