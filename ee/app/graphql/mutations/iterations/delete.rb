# frozen_string_literal: true

module Mutations
  module Iterations
    class Delete < BaseMutation
      graphql_name 'IterationDelete'

      authorize :admin_iteration

      argument :id, ::Types::GlobalIDType[::Iteration], required: true,
        description: copy_field_description(Types::IterationType, :id)

      field :group, ::Types::GroupType, null: false, description: 'Group the iteration belongs to.'

      def resolve(id:)
        iteration = authorized_find!(id: id)

        response = ::Iterations::DeleteService.new(iteration, current_user).execute

        {
          group: response.payload[:group],
          errors: response.errors
        }
      end

      private

      def find_object(id:)
        # TODO: Remove coercion when working on https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        id = ::Types::GlobalIDType[::Iteration].coerce_isolated_input(id)
        GitlabSchema.find_by_gid(id)
      end
    end
  end
end
