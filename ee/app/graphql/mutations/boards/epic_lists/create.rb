# frozen_string_literal: true

module Mutations
  module Boards
    module EpicLists
      class Create < ::Mutations::Boards::Lists::BaseCreate
        graphql_name 'EpicBoardListCreate'

        argument :board_id, ::Types::GlobalIDType[::Boards::EpicBoard],
                 required: true,
                 description: 'Global ID of the issue board to mutate.'

        field :list,
              Types::Boards::EpicListType,
              null: true,
              description: 'Epic list in the epic board.'

        authorize :admin_epic_board_list

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::Boards::EpicBoard)
        end

        def create_list(board, params)
          create_list_service =
            ::Boards::EpicLists::CreateService.new(board.group, current_user, params)

          create_list_service.execute(board)
        end
      end
    end
  end
end
