# frozen_string_literal: true

module Mutations
  module Iterations
    class Create < BaseMutation
      include Mutations::ResolvesGroup
      include ResolvesProject

      graphql_name 'CreateIteration'

      authorize :create_iteration

      field :iteration,
            Types::IterationType,
            null: true,
            description: 'The created iteration.'

      argument :group_path, GraphQL::ID_TYPE,
               required: false,
               description: "The target group for the iteration."

      argument :project_path, GraphQL::ID_TYPE,
               required: false,
               description: "The target project for the iteration."

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

        parent = find_parent(args)

        response = ::Iterations::CreateService.new(parent, current_user, args).execute

        response_object = response.payload[:iteration] if response.success?
        response_errors = response.error? ? response.payload[:errors].full_messages : []

        {
            iteration: response_object,
            errors: response_errors
        }
      end

      private

      def find_object(group_path: nil, project_path: nil)
        if group_path
          resolve_group(full_path: group_path)
        elsif project_path
          resolve_project(full_path: project_path)
        end
      end

      def find_parent(args)
        group_path = args.delete(:group_path)
        project_path = args.delete(:project_path)

        if group_path
          authorized_find!(group_path: group_path)
        elsif project_path
          authorized_find!(project_path: project_path)
        end
      end

      def validate_arguments!(args)
        if args.except(:group_path, :project_path).empty?
          raise Gitlab::Graphql::Errors::ArgumentError,
                'The list of iteration attributes is empty'
        end

        if args[:group_path].present? && args[:project_path].present?
          raise Gitlab::Graphql::Errors::ArgumentError,
                'Only one of group_path or project_path can be provided'
        end

        if args[:group_path].nil? && args[:project_path].nil?
          raise Gitlab::Graphql::Errors::ArgumentError,
                'Either group_path or project_path is required'
        end
      end
    end
  end
end
