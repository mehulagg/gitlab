# frozen_string_literal: true

module Resolvers
  module Boards
    class BoardListEpicsResolver < BaseResolver
      type Types::EpicType.connection_type, null: true

      alias_method :list, :object

      def resolve(**args)
        filter_params = { board_id: list.epic_board.id, id: list.id }
        service = ::Boards::Epics::ListService.new(list.epic_board.group, context[:current_user], filter_params)

        offset_pagination(service.execute)
      end
    end
  end
end
