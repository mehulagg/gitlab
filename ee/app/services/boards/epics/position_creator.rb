# frozen_string_literal: true

module Boards
  module Epics
    class PositionCreator < Boards::BaseService
      include Gitlab::Utils::StrongMemoize

      def execute
        validate_params!
        time = DateTime.current

        positions = epics_on_board.map.with_index(1) do |list_epic, index|
          {
            epic_id: list_epic.id,
            epic_board_id: board_id,
            relative_position: start_position * index,
            created_at: time,
            updated_at: time
          }
        end

        Boards::EpicBoardPosition.insert_all(positions, unique_by: %i[epic_board_id epic_id])
      end

      private

      def validate_params!
        raise ArgumentError, 'board_id param is missing' if params[:board_id].blank?
        raise ArgumentError, 'list_id param is missing' if params[:list_id].blank?
      end

      def start_position
        strong_memoize(:start_position) do
          last_board_position = Boards::EpicBoardPosition.last_for_board_id(board_id)
          base = last_board_position&.relative_position || 0
          base + Boards::EpicBoardPosition::IDEAL_DISTANCE
        end
      end

      def epics_on_board
        # the positions will be created for all epics with id >= from_id
        list_params = { board_id: board_id, list_id: list_id, from_id: params[:from_id] }

        Boards::Epics::ListService.new(parent, current_user, list_params).execute
      end

      def board_id
        @board_id ||= params.delete(:board_id)
      end

      def list_id
        @list_id ||= params.delete(:list_id)
      end
    end
  end
end
