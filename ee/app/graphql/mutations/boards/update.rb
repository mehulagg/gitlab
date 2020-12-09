# frozen_string_literal: true

module Mutations
  module Boards
    class Update < ::Mutations::BaseMutation
      graphql_name 'UpdateBoard'

      argument :id,
               ::Types::GlobalIDType[::Board],
               required: true,
               description: 'The board global ID'

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
               ::Types::GlobalIDType[::User],
               required: false,
               loads: ::Types::UserType,
               description: 'The ID of user to be assigned to the board'

      # Cannot pre-load ::Types::MilestoneType because we are also assigning values like:
      # ::Timebox::None(0), ::Timebox::Upcoming(-2) or ::Timebox::Started(-3), that cannot be resolved to a DB record.
      argument :milestone_id,
               ::Types::GlobalIDType[::Milestone],
               required: false,
               description: 'The ID of milestone to be assigned to the board'

      # Cannot pre-load ::Types::IterationType because we are also assigning values like:
      # ::Iteration::Constants::None(0) or ::Iteration::Constants::Current(-4), that cannot be resolved to a DB record.
      argument :iteration_id,
               ::Types::GlobalIDType[::Iteration],
               required: false,
               description: 'The ID of iteration to be assigned to the board.'

      argument :weight,
               GraphQL::INT_TYPE,
               required: false,
               description: 'The weight value to be assigned to the board'

      argument :labels, [GraphQL::STRING_TYPE],
               required: false,
               description: copy_field_description(Types::IssueType, :labels)

      argument :label_ids, [::Types::GlobalIDType[::Label]],
               required: false,
               description: 'The IDs of labels to be added to the board'

      field :board,
            Types::BoardType,
            null: true,
            description: "The board after mutation"

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

      def ready?(**args)
        if args.slice(*mutually_exclusive_args).size > 1
          arg_str = mutually_exclusive_args.map { |x| x.to_s.camelize(:lower) }.join(' or ')
          raise Gitlab::Graphql::Errors::ArgumentError, "one and only one of #{arg_str} is required"
        end

        super
      end

      private

      def find_object(id:)
        # TODO: remove this line when the compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        id = ::Types::GlobalIDType[::Board].coerce_isolated_input(id)
        GitlabSchema.find_by_gid(id)
      end

      def parse_arguments(args = {})
        if args[:assignee_id]
          # TODO: remove this line when the compatibility layer is removed
          # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
          args[:assignee_id] = ::Types::GlobalIDType[::User].coerce_isolated_input(args[:assignee_id])
          args[:assignee_id] = args[:assignee_id].model_id
        end

        if args[:milestone_id]
          # TODO: remove this line when the compatibility layer is removed
          # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
          args[:milestone_id] = ::Types::GlobalIDType[::Milestone].coerce_isolated_input(args[:milestone_id])
          args[:milestone_id] = args[:milestone_id].model_id
        end

        args[:label_ids] &&= args[:label_ids].map do |label_id|
          ::GitlabSchema.parse_gid(label_id, expected_type: ::Label).model_id
        end

        # we need this because we also pass `gid://gitlab/Iteration/-4` or `gid://gitlab/Iteration/-4`
        # as `iteration_id` when we scope board to `Iteration::Constants::Current` or `Iteration::Constants::None`
        args[:iteration_id] = args[:iteration_id].model_id if args[:iteration_id]
        args
      end

      def mutually_exclusive_args
        [:labels, :label_ids]
      end
    end
  end
end
