# frozen_string_literal: true

module Mutations
  module Boards
    class Update < ::Mutations::BaseMutation
      graphql_name 'UpdateBoard'

      argument :id,
               GraphQL::ID_TYPE,
               required: true,
               description: 'The board global id.'

      argument :name,
                GraphQL::STRING_TYPE,
                required: false,
                description: copy_field_description(Types::BoardType, :name)

      argument :hide_backlog_list,
               GraphQL::BOOLEAN_TYPE,
               required: false,
               description: copy_field_description(Types::BoardType, :hide_backlog_list)

      argument :hide_closed_list,
               GraphQL::BOOLEAN_TYPE,
               required: false,
               description: copy_field_description(Types::BoardType, :hide_closed_list)

      argument :assignee_id,
               GraphQL::ID_TYPE,
               required: false,
               loads: ::Types::UserType,
               description: 'The id of user to be assigned to the board.'

      argument :milestone_id,
               GraphQL::ID_TYPE,
               required: false,
               description: 'The id of milestone to be assigned to the board.'

      argument :weight,
               GraphQL::INT_TYPE,
               required: false,
               description: 'The weight value to be assigned to the board.'

      field :board,
            Types::BoardType,
            null: true,
            description: "The board after mutation."

      authorize :admin_board

      def resolve(id:, assignee: nil, **args)
        board = authorized_find!(id: id)

        parsed_params = parse_arguments(args)

        ::Boards::UpdateService.new(board.resource_parent, current_user, parsed_params).execute(board)

        {
          board: board,
          errors: errors_on_object(board)
        }
      end

      private

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end

      def parse_arguments(args = {})
        if args[:assignee_id]
          args[:assignee_id] = GitlabSchema.parse_gid(args[:assignee_id], expected_type: ::User).model_id
        end

        if args[:milestone_id]
          args[:milestone_id] = GitlabSchema.parse_gid(args[:milestone_id], expected_type: ::Milestone).model_id
        end

        args
      end
    end
  end
end
