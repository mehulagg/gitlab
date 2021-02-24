# frozen_string_literal: true

module Mutations
  module Boards
    module EpicBoards
      class Update < ::Mutations::BaseMutation
        include Mutations::ResolvesGroup
        include Mutations::Boards::CommonMutationArguments # TODO: check

        graphql_name 'EpicBoardUpdate'

        authorize :admin_epic_board

        argument :id,
                 ::Types::GlobalIDType[::EpicBoard],
                 required: true,
                 description: 'The epic board global ID.'

        field :epic_board,
              Types::Boards::EpicBoardType,
              null: true,
              description: 'The updated epic board.'

        def resolve(id:, **args)
          board = authorized_find!(id: id)

          ::Boards::EpicBoards::UpdateService.new(board.resource_parent, current_user, args).execute(board)

          {
            board: board,
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
