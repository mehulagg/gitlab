# frozen_string_literal: true

require 'rubocop-rspec'

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after the last `let_it_be` block.
      #
      # @example
      #   # bad
      #   let_it_be(:foo) { bar }
      #   let_it_be(:something) { other }
      #   it { does_something }
      #
      #   # good
      #   let_it_be(:foo) { bar }
      #   let_it_be(:something) { other }
      #
      #   it { does_something }
      class EmptyLineAfterFinalLetItBe < RuboCop::Cop::Base
        extend RuboCop::Cop::AutoCorrector
        include RuboCop::RSpec::EmptyLineSeparation
        include RuboCop::RSpec::Language::NodePattern

        MSG = 'Add an empty line after the last `let_it_be`.'

        def_node_matcher :let_it_be?, <<-PATTERN
          {
            (block (send #rspec? :let_it_be ...) ...)
            (send #rspec? :let_it_be _ block_pass)
          }
        PATTERN

        def on_block(node)
          return unless example_group_with_body?(node)

          final_let_it_be = node.body.child_nodes.reverse.find { |child| let_it_be?(child) }

          return if final_let_it_be.nil?

          missing_separating_line_offense(final_let_it_be) { MSG }
        end
      end
    end
  end
end
