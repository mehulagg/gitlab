# frozen_string_literal: true

module Mutations
  module Iterations
    class Update < BaseMutation
      include Mutations::ResolvesGroup
      include ResolvesProject

      graphql_name 'UpdateIteration'

      authorize :admin_iteration

      field :iteration,
            Types::IterationType,
            null: true,
            description: 'The updated iteration'

      argument :group_path, GraphQL::ID_TYPE,
               required: true,
               description: "The group of the iteration"

      argument :id,
               GraphQL::ID_TYPE,
               required: true,
               description: 'The id of the iteration'

      argument :title,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The title of the iteration'

      argument :description,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The description of the iteration'

      argument :start_date,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The start date of the iteration'

      argument :due_date,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The end date of the iteration'

      def resolve(args)
        validate_arguments!(args)

        parent = resolve_group(full_path: args[:group_path]).try(:sync)
        iteration = authorized_find!(parent: parent, id: args[:id])

        response = ::Iterations::UpdateService.new(parent, current_user, args).execute(iteration)

        response_object = response.payload[:iteration] if response.success?
        response_errors = response.error? ? (response.payload[:errors] || response.message) : []

        {
            iteration: response_object,
            errors: response_errors
        }
      end

      private

      def find_object(parent:, id:)
        ::Resolvers::IterationsResolver.new(object: parent, context: context, field: nil).resolve(id: id).items.first
      end

      def validate_arguments!(args)
        raise Gitlab::Graphql::Errors::ArgumentError, 'The list of iteration attributes is empty' if args.except(:group_path, :id).empty?
      end
    end
  end
end
