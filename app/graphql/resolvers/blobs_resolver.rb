# frozen_string_literal: true

module Resolvers
  class BlobsResolver < BaseResolver
    type Types::Tree::BlobType, null: true

    calls_gitaly!

    argument :paths, [GraphQL::STRING_TYPE],
             required: true,
             description: 'Array of desired blob paths.'
    argument :ref, GraphQL::STRING_TYPE,
             required: false,
             default_value: :head,
             description: 'The commit ref to get the blobs from. Default value is HEAD.'

    alias_method :repository, :object

    def resolve(paths:, ref:)
      ref = repository.root_ref if ref == :head

      args = paths.map { |path| [ref, path] }

      Gitlab::Graphql::Representation::TreeEntry.decorate(repository.blobs_at(args), repository)
    end
  end
end
