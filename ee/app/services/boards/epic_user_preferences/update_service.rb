# frozen_string_literal: true

module Boards
  module EpicUserPreferences
    class UpdateService < BaseService
      def initialize(user, board, epic, preferences = {})
        @current_user = user
        @board = board
        @epic = epic
        @preferences = preferences
      end

      def execute
        return error('User not set') unless current_user

        preference = current_user.find_or_init_board_epic_preference(
          board_id: board.id, epic_id: epic.id)

        if preference.update(allowed_preferences)
          success(epic_user_preferences: preference)
        else
          error(preference.errors.to_sentence)
        end
      end

      private

      attr_accessor :current_user, :board, :epic, :preferences

      def allowed_preferences
        preferences.slice(:collapsed)
      end
    end
  end
end
