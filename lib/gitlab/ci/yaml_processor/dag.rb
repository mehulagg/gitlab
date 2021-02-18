# frozen_string_literal: true

# Represents Dag pipeline
module Gitlab
  module Ci
    class YamlProcessor
      class Dag
        include TSort

        MissingNodeError = Class.new(StandardError)

        def initialize(nodes)
          @nodes = nodes
        end

        def tsort_each_child(node, &block)
          raise MissingNodeError, "node #{node} is missing" unless @nodes[node]

          @nodes[node].each(&block)
        end

        def tsort_each_node(&block)
          @nodes.each_key(&block)
        end
      end
    end
  end
end
