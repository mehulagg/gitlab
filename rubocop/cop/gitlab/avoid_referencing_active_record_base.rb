# frozen_string_literal: true

module RuboCop
  module Cop
    module Gitlab
      # @example
      #   # bad
      #   ActiveRecord::Base.connection
      #
      #   # good
      #   ApplicationRecord.connection
      #
      class AvoidReferencingActiveRecordBase < RuboCop::Cop::Cop
        MSG = 'Do not use ActiveRecord::Base.connection, use ApplicationRecord.connection instead'

        def_node_matcher :connection_referenced?, <<~PATTERN
        (send (const (const nil? :ActiveRecord) :Base) :connection)
        PATTERN

        def on_send(node)
          return unless connection_referenced?(node)

          add_offense(node, location: :expression)
        end
      end
    end
  end
end
