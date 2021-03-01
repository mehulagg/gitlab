# frozen_string_literal: true

module Mutations
  module Iterations
    module Cadences
      class Update < BaseMutation
        include Mutations::ResolvesGroup

        graphql_name 'UpdateIterationsCadence'

        authorize :update_iterations_cadence

        argument :id, ::Types::GlobalIDType[::Iterations::Cadence], required: true,
                 description: copy_field_description(Types::Iterations::CadenceType, :id)

        argument :group_path, GraphQL::ID_TYPE, required: true, description: 'Group of the iteration.'

        argument :title, GraphQL::STRING_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :title)

        argument :duration_in_weeks, GraphQL::INT_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :duration_in_weeks)

        argument :iterations_in_advance, GraphQL::INT_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :iterations_in_advance)

        argument :start_date, Types::TimeType, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :start_date)

        argument :automatic, GraphQL::BOOLEAN_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :automatic)

        argument :active, GraphQL::BOOLEAN_TYPE, required: false,
          description: copy_field_description(Types::Iterations::CadenceType, :active)

        field :iterations_cadence, Types::Iterations::CadenceType, null: true,
          description: 'The updated iterations cadence.'

        def resolve(args)
          iterations_cadence = authorized_find!(id: args[:id])
        end

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_class: ::Iterations::Cadence)
        end
      end
    end
  end
end
