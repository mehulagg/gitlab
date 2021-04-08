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

      field :size, GraphQL::INT_TYPE, null: true,
            description: 'Size (in bytes) of the blob.'
      field :raw_size, GraphQL::INT_TYPE, null: true,
            description: 'Size (in bytes) of the blob, or the blob target if stored externally.'

#      field :file_type (e.g. 'text')
=begin
      field :raw_blob, GraphQL::STRING_TYPE, null: true, method: :raw_blob?,
            description: 'Whether'

      tooLarge (too large to view)

      editBlobPath (same path that is currently returned by edit_blob_button, eventually we'll implement a Vue solution)

      ideEditPath (same path that is currently returned by ide_edit_button)

      storedExternally (boolean to prevent users from modifying files that are stored externally)

      rawPath (same as path in blob_helper, used for download)

      externalStorageUrl (needed for Open raw button)

      replacePath (endpoint used for replace button)

      deletePath (endpoint used for delete button)

      canModifyBlob (same boolean that is currently used in the blob_helper)

      forkPath (used when the user doesn't have permission to modify, we display a 'Fork' button)

      simpleViewer (similar to snippets graphql endpoint, to determine which viewer to use on the FE)

      richViewer (similar to snippets graphql endpoint, to determine which viewer to use on the FE)
=end
      def lfs_oid
        Gitlab::Graphql::Loaders::BatchLfsOidLoader.new(object.repository, object.id).find
      end
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end

Types::Tree::BlobType.prepend_if_ee('::EE::Types::Tree::BlobType')
