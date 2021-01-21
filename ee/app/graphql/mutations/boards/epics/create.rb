# frozen_string_literal: true

module Mutations
  module Boards
    module Epics
      class Create < ::Mutations::BaseMutation
        include Mutations::ResolvesGroup
        include Mutations::Boards::CommonMutationArguments

        graphql_name 'EpicBoardCreate'

        authorize :admin_epic_board

        field :epic_board,
              Types::Boards::EpicBoardType,
              null: true,
              description: 'Created epic board.'

        def resolve(args)
          group_path = args.delete(:group_path)

          group = authorized_find!(group_path: group_path)
          service_response = ::Boards::Epics::CreateService.new(group, current_user, args).execute

          {
            epic_board: service_response.payload,
            errors: service_response.errors
          }
        end

        private

        def find_object(group_path:)
          resolve_group(full_path: group_path)
        end
      end
    end
  end
end
