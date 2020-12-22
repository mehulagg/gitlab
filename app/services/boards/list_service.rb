# frozen_string_literal: true

module Boards
  class ListService < Boards::BaseService
    def execute(create_default_board: true)
      create_board! if create_default_board && parent.boards.empty?

      find_boards
    end

    private

    def boards
      if params[:board_type] == :epic
        # TODO: move to EE
        parent.epic_boards
      else
        parent.boards
      end
    end

    def create_board!
      Boards::CreateService.new(parent, current_user).execute
    end

    def find_boards
      found =
        if parent.multiple_issue_boards_available?
          boards.order_by_name_asc
        else
          # When multiple issue boards are not available
          # a user is only allowed to view the default shown board
          boards.first_board
        end

      params[:board_id].present? ? [found.find(params[:board_id])] : found
    end
  end
end
