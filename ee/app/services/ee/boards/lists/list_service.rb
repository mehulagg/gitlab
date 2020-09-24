# frozen_string_literal: true

module EE
  module Boards
    module Lists
      module ListService
        extend ::Gitlab::Utils::Override

        # When adding a new licensed type, make sure to also add
        # it on license.rb with the pattern "board_<list_type>_lists"
        LICENSED_LIST_TYPES = %i[assignee milestone].freeze

        override :execute
        def execute(board, create_default_lists: true)
          list_types = unavailable_list_types_for(board)

          super.without_types(list_types)
        end

        private

        def unavailable_list_types_for(board)
          (hidden_lists_for(board) + unlicensed_lists_for(board)).uniq
        end

        def hidden_lists_for(board)
          hidden = []

          hidden << ::List.list_types[:backlog] if board.hide_backlog_list
          hidden << ::List.list_types[:closed] if board.hide_closed_list

          hidden
        end

        def unlicensed_lists_for(board)
          parent = board.resource_parent

          LICENSED_LIST_TYPES.each_with_object([]) do |list_type, lists|
            list_type_key = ::List.list_types[list_type]
            lists << list_type_key unless parent&.feature_available?(:"board_#{list_type}_lists")
          end
        end
      end
    end
  end
end
