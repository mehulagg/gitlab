# frozen_string_literal: true

module Boards
  module Epics
    class MoveService < Boards::BaseItemMoveService
      private

      def update(epic, epic_modification_params)
        ::Epics::UpdateService.new(epic.group, current_user, epic_modification_params).execute(epic)
      end

      def board
        @board ||= parent.epic_boards.find(params[:board_id])
      end
    end
  end
end
