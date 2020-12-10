# frozen_string_literal: true

module Boards
  module Lists
    class ListService < BaseListService
      private

      def board_lists(board)
        board.lists
      end

      def preload_lists(board)
        board_lists(board).preload_associated_models
      end
    end
  end
end

Boards::Lists::ListService.prepend_if_ee('EE::Boards::Lists::ListService')
