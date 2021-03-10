# frozen_string_literal: true

module Mutations
  module Boards
    module EpicBoards
      class EpicMoveList < ::Mutations::BaseMutation
        graphql_name 'EpicMoveList'

        authorize :admin_epic_board

        argument :board_id, ::Types::GlobalIDType[::Boards::EpicBoard],
                  required: true,
                  description: 'Global ID of the board that the epic is in.'

        argument :epic_id, ::Types::GlobalIDType[::Epic],
                  required: true,
                  description: 'ID of the epic to mutate.'

        argument :from_list_id, ::Types::GlobalIDType[::Boards::EpicList],
                  required: true,
                  description: 'ID of the board list that the epic will be moved from.'

        argument :to_list_id, ::Types::GlobalIDType[::Boards::EpicList],
                  required: true,
                  description: 'ID of the board list that the epic will be moved to.'

        def resolve(**args)
          board = authorized_find!(id: args[:board_id])
          epic = authorized_find!(id: args[:epic_id])

          unless Feature.enabled?(:epic_boards, board.resource_parent)
            raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'epic_boards feature is disabled'
          end

          move_epic(board, epic, move_list_arguments(args).merge(board_id: board.id))

          {
            epic: epic.reset,
            errors: epic.errors.full_messages
          }
        end

        private

        def find_object(id:)
          GitlabSchema.find_by_gid(id)
        end

        def move_epic(board, epic, move_params)
          service = ::Boards::Epics::MoveService.new(board.resource_parent, current_user, move_params)

          service.execute(epic)
        end

        def move_list_arguments(args)
          {
            from_list_id: args[:from_list_id].find&.id,
            to_list_id: args[:to_list_id].find&.id
          }
        end
      end
    end
  end
end
