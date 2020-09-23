# frozen_string_literal: true

module Mutations
  module Namespaces
    class Base < ::Mutations::BaseMutation
      argument :id, GraphQL::ID_TYPE,
               required: true,
               description: "The global id of the namespace to mutate"

      field :namespace,
            Types::NamespaceType,
            null: true,
            description: 'The namespace after mutation'

      private

      def find_object(id:)
        GitlabSchema.object_from_id(id)
      end
    end
  end
end
