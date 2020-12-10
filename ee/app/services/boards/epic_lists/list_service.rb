# frozen_string_literal: true

module Boards
  module EpicLists
    class ListService < ::Boards::Lists::BaseListService
      private

      def board_lists(board)
        board.epic_lists
      end

      def preload_lists(board)
        board_lists(board)
      end
    end
  end
end
