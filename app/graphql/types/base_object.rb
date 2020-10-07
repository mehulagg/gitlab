# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    prepend Gitlab::Graphql::Present
    prepend Gitlab::Graphql::ExposePermissions
    prepend Gitlab::Graphql::MarkdownField

    field_class Types::BaseField

    HIGH_COMPLEXITY = 10

    # All graphql fields exposing an id, should expose a global id.
    def id
      GitlabSchema.id_from_object(object)
    end

    def current_user
      context[:current_user]
    end
  end
end
