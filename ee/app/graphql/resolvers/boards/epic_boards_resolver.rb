# frozen_string_literal: true

module Resolvers
  module Boards
    class EpicBoardsResolver < BaseResolver
      type Types::Boards::EpicBoardType.connection_type, null: true

      def resolve(**args)
        return [] unless object.feature_available?(:epics)

        object.epic_boards.order_by_name_asc
      end
    end
  end
end
