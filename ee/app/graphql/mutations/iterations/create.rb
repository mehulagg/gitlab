# frozen_string_literal: true

module Mutations
  module Iterations
    class Create < BaseMutation
      include Mutations::ResolvesResourceParent

      graphql_name 'CreateIteration'

      authorize :create_iteration

      field :iteration,
            Types::IterationType,
            null: true,
            description: 'The created iteration.'

      argument :title,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The title of the iteration.'

      argument :description,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The description of the iteration.'

      argument :start_date,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The start date of the iteration.'

      argument :due_date,
               GraphQL::STRING_TYPE,
               required: false,
               description: 'The end date of the iteration.'

      def resolve(args)
        validate_arguments!(args)

        parent = authorized_resource_parent_find!(args)

        response = ::Iterations::CreateService.new(parent, current_user, args).execute

        response_object = response.payload[:iteration] if response.success?
        response_errors = response.error? ? response.payload[:errors].full_messages : []

        {
            iteration: response_object,
            errors: response_errors
        }
      end

      private

      def validate_arguments!(args)
        if args.except(:group_path, :project_path).empty?
          raise Gitlab::Graphql::Errors::ArgumentError,
                'The list of iteration attributes is empty'
        end
      end
    end
  end
end
