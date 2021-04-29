# frozen_string_literal: true

module Mutations
  module Iterations
    class Destroy < BaseMutation
      graphql_name 'DestroyIteration'

      authorize :admin_iteration

      argument :id, ::Types::GlobalIDType[::Iteration], required: true,
        description: copy_field_description(Types::IterationType, :id)

      field :group, ::Types::GroupType, null: false, description: 'Group the iteration belongs to.'

      def resolve(id:)
        iteration = authorized_find!(id: id)

        iteration.destroy

        {
          group: iteration.group,
          errors: []
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
