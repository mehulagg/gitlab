# frozen_string_literal: true

module Mutations
  module Boards
    module Epics
      class Create < ::Mutations::BaseMutation
        include Mutations::ResolvesGroup

        graphql_name 'CreateEpicInBoardList'

        argument :group_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The group the epic to create is in.'

        argument :board_id, ::Types::GlobalIDType[::Boards::EpicBoard],
                 required: true,
                 description: 'Global ID of the board that the epic is in.'

        argument :list_id, ::Types::GlobalIDType[::Boards::EpicList],
                 required: true,
                 description: 'Global ID of the epic board list in which epic will be created.'

        argument :title,
                 GraphQL::STRING_TYPE,
                 required: false,
                 description: 'The title of the epic.'

        field :epic,
              Types::EpicType,
              null: true,
              description: 'The epic after creation.'

        authorize :create_epic

        def ready?(args)
          ServiceResponse.error(message: _('Title required')) if args[:title].blank?
        end

        def resolve(**args)
          group_path = args.delete(:group_path)

          group = authorized_find!(group_path: group_path)

          response = ::Boards::Epics::CreateService.new(group, current_user, create_epic_params(args)).execute

          mutation_response(response.success? ? response.payload : nil, response.errors)
        end

        private

        def mutation_response(epic, errors)
          {
              epic: epic,
              errors: Array.wrap(errors)
          }
        end

        def find_object(group_path:)
          resolve_group(full_path: group_path)
        end

        def create_epic_params(args)
          args[:list_id] &&= ::GitlabSchema.parse_gid(args[:list_id], expected_type: ::Boards::EpicList).model_id
          args[:board_id] &&= ::GitlabSchema.parse_gid(args[:board_id], expected_type: ::Boards::EpicBoard).model_id

          args.with_indifferent_access
        end
      end
    end
  end
end
