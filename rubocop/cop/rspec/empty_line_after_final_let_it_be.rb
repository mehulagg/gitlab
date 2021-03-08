# frozen_string_literal: true

require 'rubocop-rspec'

module RuboCop
  module Cop
    module RSpec
      class EmptyLineAfterFinalLetItBe < RuboCop::Cop::RSpec::Base
        MSG = 'Add an empty line after the last `%<let>s`.'

        def_node_matcher :let_it_be?, <<-PATTERN
          {
            #{block_pattern('#Helpers.all')}
            (send #rspec? #Helpers.all _ block_pass)
          }
        PATTERN

        def on_block(node)
          return unless example_group_with_body?(node)

          final_let = node.body.child_nodes.reverse.find { |child| let_it_be?(child) }

          return if final_let.nil?

          missing_separating_line_offense(final_let) do |method|
            format(MSG, let: method)
          end
        end
      end
    end
  end
end
