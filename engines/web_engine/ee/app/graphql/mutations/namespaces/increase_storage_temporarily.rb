# frozen_string_literal: true

module Mutations
  module Namespaces
    class IncreaseStorageTemporarily < Base
      graphql_name "NamespaceIncreaseStorageTemporarily"

      authorize :admin_namespace

      def resolve(args)
        namespace = authorized_find!(id: args[:id])

        namespace.enable_temporary_storage_increase!

        { namespace: namespace, errors: namespace.errors.full_messages }
      end
    end
  end
end
