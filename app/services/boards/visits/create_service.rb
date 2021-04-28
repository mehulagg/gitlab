# frozen_string_literal: true

module Boards
  module Visits
    class CreateService < Boards::BaseService
      def execute(board)
        return unless current_user && Gitlab::Database.read_write?
        return unless board

        if board.is_a?(Boards::EpicBoard)
          Boards::EpicBoardRecentVisit.visited!(current_user, board)
        elsif parent.is_a?(Group)
          BoardGroupRecentVisit.visited!(current_user, board)
        else
          BoardProjectRecentVisit.visited!(current_user, board)
        end
      end
    end
  end
end
