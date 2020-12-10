# frozen_string_literal: true

module EE
  module Boards
    module Lists
      module BaseListService
        extend ::Gitlab::Utils::Override

        override :execute
        def execute(board, create_default_lists: true)
          list_types = unavailable_list_types_for(board)

          super.without_types(list_types)
        end

        private

        def unavailable_list_types_for(board)
          hidden = []

          hidden << ::List.list_types[:backlog] if board.hide_backlog_list
          hidden << ::List.list_types[:closed] if board.hide_closed_list

          hidden
        end
      end
    end
  end
end
