# frozen_string_literal: true
module Types
  module Tree
    # rubocop: disable Graphql/AuthorizeTypes
    # This is presented through `Repository` that has its own authorization
    class BlobType < BaseObject
      implements Types::Tree::EntryType

      present_using BlobPresenter

      graphql_name 'Blob'

      field :web_url, GraphQL::STRING_TYPE, null: true,
            description: 'Web URL of the blob.'
      field :web_path, GraphQL::STRING_TYPE, null: true,
            description: 'Web path of the blob.'
      field :lfs_oid, GraphQL::STRING_TYPE, null: true,
            calls_gitaly: true,
            description: 'LFS ID of the blob.'
      field :mode, GraphQL::STRING_TYPE, null: true,
            description: 'Blob mode in numeric format.'

      def lfs_oid
        Gitlab::Graphql::Loaders::BatchLfsOidLoader.new(object.repository, object.id).find
      end

      def type
        if object.is_a?(::Blob)
          :blob
        else
          super
        end
      end

      def flat_path
        if object.is_a?(::Blob)
          object.path
        else
          super
        end
      end
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
