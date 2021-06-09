# frozen_string_literal: true

module Boards
  module Epics
    class ListService < Boards::BaseItemsListService
      private

      def finder
        EpicsFinder.new(current_user, filter_params.merge(group_id: parent.id))
      end

      def filter(items)
        return super unless params[:from_id].present?

        super.from_id(params[:from_id])
      end

      def board
        @board ||= parent.epic_boards.find(params[:board_id])
      end

      def ordered_items
        items.order_relative_position_on_board(board.id)
      end

      def item_model
        ::Epic
      end
    end
  end
end
