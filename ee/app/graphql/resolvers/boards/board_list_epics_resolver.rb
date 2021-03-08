# frozen_string_literal: true

module Resolvers
  module Boards
    class BoardListEpicsResolver < BaseResolver
      type Types::EpicType.connection_type, null: true

      alias_method :list, :object

      argument :filters, Types::Boards::BoardIssueInputType,
         required: false,
         description: 'Filters applied when selecting issues in the board list.'

      def resolve(**args)
        # filter_params = issue_filters(args[:filters]).merge(board_id: list.board.id, id: list.id)
        filter_params = { board_id: list.epic_board.id, id: list.id }
        service = ::Boards::Epics::ListService.new(list.epic_board.group, context[:current_user], filter_params)

        offset_pagination(service.execute)
      end
    end
  end
end
