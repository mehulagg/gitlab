# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      # Cop that enforces use of namespaced classes in order to better identify
      # high level domains within the codebase.

      # bad!
      #   class MyClass
      #   end

      # good!
      #   module MyDomain
      #     class MyClass
      #     end
      #   end

      class NamespacedClass < RuboCop::Cop::Cop
        MSG = 'Classes must be declared inside a module indicating the domain namespace.'
        NAMESPACE_TYPES = %i[class module].freeze

        def on_class(node)
          add_offense(node) if !namespaced_constant?(node) && namespaces(node).empty?
        end

        private

        def namespaced_constant?(node)
          node.defined_module_name.demodulize != node.defined_module_name
        end

        def namespaces(node)
          node.ancestors.select { |ancestor| NAMESPACE_TYPES.include?(ancestor.type) }
        end
      end
    end
  end
end
