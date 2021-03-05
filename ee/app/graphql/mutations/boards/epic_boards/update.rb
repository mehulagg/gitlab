# frozen_string_literal: true

module Mutations
  module Boards
    module EpicBoards
      class Update < ::Mutations::BaseMutation
        include Mutations::Boards::CommonMutationArguments
        prepend Mutations::Boards::ScopedBoardMutation

        graphql_name 'EpicBoardUpdate'

        authorize :admin_epic_board

        argument :id,
                 ::Types::GlobalIDType[::Boards::EpicBoard],
                 required: true,
                 description: 'The epic board global ID.'

        argument :labels, [GraphQL::STRING_TYPE],
                 required: false,
                 description: 'Labels to be added to the board.'

        argument :label_ids, [::Types::GlobalIDType[::Label]],
                 required: false,
                 description: 'The IDs of labels to be added to the board.'

        field :epic_board,
              Types::Boards::EpicBoardType,
              null: true,
              description: 'The updated epic board.'

        def resolve(**args)
          board = authorized_find!(id: args[:id])

          unless Feature.enabled?(:epic_boards, board.resource_parent)
            raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'epic_boards feature is disabled'
          end

          ::Boards::EpicBoards::UpdateService.new(board.resource_parent, current_user, args).execute(board)

          {
            epic_board: board.reset,
            errors: errors_on_object(board)
          }
        end

        private

        def find_object(id:)
          GitlabSchema.find_by_gid(id)
        end
      end
    end
  end
end
