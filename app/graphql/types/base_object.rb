# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    prepend Gitlab::Graphql::Present
    prepend Gitlab::Graphql::ExposePermissions
    prepend Gitlab::Graphql::MarkdownField

    field_class Types::BaseField

    def self.removed_field(name, type, args)
      # no-op placeholder to remove fields from the documentation without removing from the codebase.
    end

    # All graphql fields exposing an id, should expose a global id.
    def id
      GitlabSchema.id_from_object(object)
    end

    def current_user
      context[:current_user]
    end
  end
end
