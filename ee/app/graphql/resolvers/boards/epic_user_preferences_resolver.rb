# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicUserPreferencesResolver < BaseResolver
      description 'Retrieve user preferences for a board epic'

      type Types::Boards::EpicUserPreferencesType, null: true

      def resolve(**args)
        board = context[:board]
        return unless board
        return unless current_user

        BatchLoader::GraphQL.for(object.id).batch(key: board) do |epic_ids, loader, args|
          ::Boards::EpicUserPreference.for_user_board_epic_ids(current_user, board, epic_ids).each { |user_pref| loader.call(user_pref.epic_id, user_pref) }
        end
      end
    end
  end
end
