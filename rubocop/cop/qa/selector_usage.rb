# frozen_string_literal: true

require_relative '../../qa_helpers'

module RuboCop
  module Cop
    module QA
      # This cop checks for the usage of data-qa-selectors or .qa-* classes in non-QA files
      #
      # @example
      #   # bad
      #   find('[data-qa-selector="the_selector"]')
      #   find('.qa-selector')
      #
      #   # good
      #   find('[data-testid="the_selector"]')
      #   find('#selector')
      class SelectorUsage < RuboCop::Cop::Cop
        include QAHelpers

        SELECTORS = /\.qa-\w+|data-qa-\w+/
        MESSAGE = %(Do not use `%s` as this is reserved for the end-to-end specs. Use a semantic attribute or a data-testid instead.)

        def on_str(node)
          return if in_qa_file?(node)

          add_offense(node, message: MESSAGE % node.value) if SELECTORS.match?(node.value)
        end
      end
    end
  end
end
