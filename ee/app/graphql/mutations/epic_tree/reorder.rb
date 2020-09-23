# frozen_string_literal: true

module Mutations
  module EpicTree
    class Reorder < ::Mutations::BaseMutation
      graphql_name "EpicTreeReorder"

      authorize :admin_epic

      argument :base_epic_id,
               GraphQL::ID_TYPE,
               required: true,
               description: 'The id of the base epic of the tree'

      argument :moved,
               Types::EpicTree::EpicTreeNodeInputType,
               required: true,
               description: 'Parameters for updating the tree positions'

      def resolve(args)
        params = args[:moved]
        moving_params = params.to_hash.slice(:adjacent_reference_id, :relative_position, :new_parent_id).merge(base_epic_id: args[:base_epic_id])

        result = ::Epics::TreeReorderService.new(current_user, params[:id], moving_params).execute
        errors = result[:status] == :error ? [result[:message]] : []

        { errors: errors }
      end
    end
  end
end
