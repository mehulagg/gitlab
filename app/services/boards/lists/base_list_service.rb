# frozen_string_literal: true

module Boards
  module Lists
    class BaseListService < Boards::BaseService
      def execute(board, create_default_lists: true)
        if create_default_lists && !board_lists.backlog.exists?
          board_lists(board).create(list_type: :backlog)
        end

        lists = preload_lists(board)
        params[:list_id].present? ? lists.where(id: params[:list_id]) : lists # rubocop: disable CodeReuse/ActiveRecord
      end

      private

      def board_lists(board)
        raise NotImplementedError
      end

      def preload_lists(board)
        raise NotImplementedError
      end
    end
  end
end

Boards::Lists::BaseListService.prepend_if_ee('EE::Boards::Lists::BaseListService')
