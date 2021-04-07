# frozen_string_literal: true

module Mutations
  module Boards
    module EpicLists
      class Destroy < ::Mutations::BaseMutation
        graphql_name 'EpicBoardListDestroy'

        argument :board_id, ::Types::GlobalIDType[::Boards::EpicList],
                 required: true,
                 description: 'Global ID of the epic board list to destroy.'

        field :list,
              Types::Boards::EpicListType,
              null: true,
              description: 'Epic list that was destroyed.'

        authorize :admin_epic_board_list

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::Boards::EpicBoard)
        end

        def destroy_list(list)
          destroy_list_service =
            ::Boards::EpicLists::DestroyService.new(list, current_user)

          destroy_list_service.execute(board)
        end
      end
    end
  end
end
