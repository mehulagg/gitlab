# frozen_string_literal: true

module Mutations
  module Boards
    module EpicLists
      class Update < BaseMutation
        graphql_name 'UpdateBoardList'

        argument :list_id, Types::GlobalIDType[Types::Boards::EpicListType],
                  required: true,
                  loads: Types::Boards::EpicListType,
                  description: 'Global ID of the list.'

        argument :collapsed, GraphQL::BOOLEAN_TYPE,
                  required: false,
                  description: 'Indicates if the list is collapsed for this user.'

        field :list,
              Types::Boards::EpicListType,
              null: true,
              description: 'Mutated list.'

        authorize :read_epic_board_list

        def resolve(list: nil, **args)
          raise_resource_not_available_error! unless can_read_list?(list)
          update_result = update_list(list, args)

          {
            list: update_result[:list],
            errors: list.errors.full_messages
          }
        end

        private

        def resolve(**args)
          service = ::Boards::Lists::UpdateService.new(list.board, current_user, args)
          service.execute(list)

          response = create_list(board, params)

          {
            list: response.success? ? response.payload[:list] : nil,
            errors: response.errors
          }
        end

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: Types::Boards::EpicListType)
        end

        # def update_list(list, args)
        #   service = ::Boards::Lists::UpdateService.new(list.board, current_user, args)
        #   service.execute(list)
        # end

        # def can_read_list?(list)
        #   return false unless list.present?

        #   Ability.allowed?(current_user, :read_issue_board_list, list.board)
        # end
      end
    end
  end
end
