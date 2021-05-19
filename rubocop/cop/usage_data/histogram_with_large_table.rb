# frozen_string_literal: true

module RuboCop
  module Cop
    module UsageData
      # This cop checks that histogram method is not used in usage_data.rb files
      # for models representing large tables, as defined by migration helpers.
      #
      # @example
      #
      # # bad
      # histogram(Issue, buckets: 1..100)
      # histogram(User.active, buckets: 1..100)
      class HistogramWithLargeTable < RuboCop::Cop::Cop
        include RuboCop::MigrationHelpers

        MSG = 'Avoid histogram method on %{model_name}'

        # Match one level const as Issue, Gitlab
        def_node_matcher :one_level_node, <<~PATTERN
          (send nil? :histogram
            (send
              (const {nil? cbase} $...)
            $...)
          $...)
        PATTERN

        # Match two level const as ::Clusters::Cluster, ::Ci::Pipeline
        def_node_matcher :two_level_node, <<~PATTERN
          (send nil? :histogram
            (send
              (const
                (const {nil? cbase} $...)
              $...)
            $...)
          $...)
        PATTERN

        def on_send(node)
          one_level_matches = one_level_node(node)
          two_level_matches = two_level_node(node)

          return unless Array(one_level_matches).any? || Array(two_level_matches).any?

          if one_level_matches
            class_name = one_level_matches[0].first
          else
            class_name = "#{two_level_matches[0].first}::#{two_level_matches[1].first}".to_sym
          end

          if large_table?(class_name)
            add_offense(node, location: :expression, message: format(MSG, model_name: class_name))
          end
        end

        private

        def large_table?(model)
          table_name = model.to_s.constantize.table_name

          high_traffic_tables.include?(table_name)
        end
      end
    end
  end
end
