# frozen_string_literal: true

module Mutations
  module Iterations
    module Cadences
      class Create < BaseMutation
        include Mutations::ResolvesGroup

        graphql_name 'CreateIterationsCadence'

        authorize :create_iterations_cadence

        argument :group_path, GraphQL::ID_TYPE, required: true,
          description: "The group the iteration cadence is created in."

        argument :title, GraphQL::STRING_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :title)

        argument :duration_in_weeks, GraphQL::INT_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :duration_in_weeks)

        argument :iterations_in_advance, GraphQL::INT_TYPE, required: false, default_value: 1,
          description: copy_field_description(Types::Iterations::CadenceType, :iterations_in_advance)

        argument :start_date, Types::TimeType, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :start_date)

        argument :automatic, GraphQL::BOOLEAN_TYPE, required: false, default_value: false,
          description: copy_field_description(Types::Iterations::CadenceType, :automatic)

        argument :active, GraphQL::BOOLEAN_TYPE, required: false, default_value: false,
          description: copy_field_description(Types::Iterations::CadenceType, :active)

        field :iterations_cadence, Types::Iterations::CadenceType, null: true,
          description: 'The created iteration cadence.'

        def resolve(args)
          validate_arguments!(args)

          group = authorized_find!(group_path: args.delete(:group_path))

          response = ::Iterations::Cadences::CreateService.new(group, current_user, args).execute

          response_object = response.payload[:iterations_cadence] if response.success?
          response_errors = response.error? ? response.payload[:errors].full_messages : []

          {
            iterations_cadence: response_object,
            errors: response_errors
          }
        end

        private

        def find_object(group_path:)
          resolve_group(full_path: group_path)
        end

        def validate_arguments!(args)
          if args.empty?
            raise Gitlab::Graphql::Errors::ArgumentError,
              'The list of epic attributes is empty'
          end
        end
      end
    end
  end
end
