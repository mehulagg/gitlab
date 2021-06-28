# frozen_string_literal: true

module Resolvers
  class TreeConnectionResolver < BaseResolver
    type Types::Tree::TreeType.connection_type, null: true
    extension Gitlab::Graphql::Extensions::ExternallyPaginatedArrayExtension

    calls_gitaly!

    argument :path, GraphQL::STRING_TYPE,
              required: false,
              default_value: '',
              description: 'The path to get the tree for. Default value is the root of the repository.'
    argument :ref, GraphQL::STRING_TYPE,
              required: false,
              default_value: :head,
              description: 'The commit ref to get the tree for. Default value is HEAD.'
    argument :recursive, GraphQL::BOOLEAN_TYPE,
              required: false,
              default_value: false,
              description: 'Used to get a recursive tree. Default is false.'

    alias_method :repository, :object

    def resolve(**args)
      return unless repository.exists?

      limit = args.delete(:max_page_size) || 100
      cursor = args.delete(:after)
      pagination_params = { limit: limit, page_token: cursor }
      tree = repository.tree(args[:ref], args[:path], recursive: args[:recursive], pagination_params: pagination_params)

      next_cursor = tree.cursor&.page_cursor
      Gitlab::Graphql::ExternallyPaginatedArray.new(nil, next_cursor, *tree)
    end

    def self.field_options
      super.merge(connection: false) # we manage the pagination manually, so opt out of the connection field extension
    end
  end
end
