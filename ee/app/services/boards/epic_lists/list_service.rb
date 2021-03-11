# frozen_string_literal: true

module Boards
  module EpicLists
    class ListService < ::Boards::Lists::ListService
      def unavailable_list_types_for(board)
        hidden = []

        hidden << ::Boards::EpicList.list_types[:backlog] if board.hide_backlog_list
        hidden << ::Boards::EpicList.list_types[:closed] if board.hide_closed_list

        hidden
      end
    end
  end
end
