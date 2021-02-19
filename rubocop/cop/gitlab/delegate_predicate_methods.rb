# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      # This cop looks for delegations to predicate methods with
      # :allow_nil option. Define a method to handle `nil` and
      # returns the correct Boolean value instead.
      #
      # @example
      #   # bad
      #   delegate :is_foo?, to: :bar, allow_nil: true
      #
      #   # good
      #   def is_foo?
      #     return false unless bar
      #     bar.is_foo?
      #   end
      class DelegatePredicateMethods < RuboCop::Cop::Cop
        MSG = "Using `delegate` with `allow_nil` on the following predicate methods are discouraged: %s."
        RESTRICT_ON_SEND = %i[delegate].freeze
        def_node_matcher :predicate_allow_nil_option, <<~PATTERN
          (send nil? :delegate
            (sym $_)*
            (hash <$(pair (sym :allow_nil) true) ...>)
          )
        PATTERN

        def on_send(node)
          predicate_allow_nil_option(node) do |delegated_methods, _options|
            offensive_methods = delegated_methods.filter_map { _1.to_s if _1.end_with?('?') }
            next if offensive_methods.empty?

            add_offense(node, message: format(MSG, offensive_methods.join(', ')))
          end
        end
      end
    end
  end
end
