# frozen_string_literal: true

module Boards
  module UserPreferences
    class UpdateService
      attr_accessor :user, :params

      def initialize(user, params = {})
        @user = user
        @params = params
      end

      def execute(board)
        return false unless user

        preference = board.user_preferences.safe_find_or_create_by!(user: user, board: board)

        preference.update(sanitized_params)
      end

      private

      def sanitized_params
        params.slice(:hide_labels)
      end
    end
  end
end
