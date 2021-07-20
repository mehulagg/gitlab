# frozen_string_literal: true

module Mutations
  module Boards
    module EpicLists
      class Update < ::Mutations::Boards::Lists::BaseUpdate
        graphql_name 'UpdateEpicBoardList'

        argument :list_id, Types::GlobalIDType[::Boards::EpicList],
                  required: true,
                  loads: Types::Boards::EpicListType,
                  description: 'Global ID of the epic list.'

        field :list,
              Types::Boards::EpicListType,
              null: true,
              description: 'Mutated epic list.'

        private

        def update_list(list, args)
          service = ::Boards::EpicLists::UpdateService.new(list.board, current_user, args)
          service.execute(list)
        end

        def can_read_list?(list)
          Ability.allowed?(current_user, :read_epic_board_list, list.board)
        end
      end
    end
  end
end
