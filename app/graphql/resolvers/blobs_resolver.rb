# frozen_string_literal: true

module Resolvers
  class BlobsResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource

    type Types::Tree::BlobType.connection_type, null: true
    authorize :download_code
    calls_gitaly!

    alias_method :repository, :object

    argument :paths, [GraphQL::STRING_TYPE],
             required: true,
             description: 'Array of desired blob paths.'
    argument :ref, GraphQL::STRING_TYPE,
             required: false,
             default_value: nil,
             description: 'The commit ref to get the blobs from. Default value is HEAD.'

    def resolve(paths:, ref:)
      authorize!(repository.container)

      return [] if repository.empty?

      ref ||= repository.root_ref

      repository.blobs_at(paths.map { |path| [ref, path] })
    end
  end
end
