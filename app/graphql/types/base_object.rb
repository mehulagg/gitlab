# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    prepend Gitlab::Graphql::Present
    prepend Gitlab::Graphql::ExposePermissions
    prepend Gitlab::Graphql::MarkdownField
    extend Gitlab::Graphql::Laziness

    field_class Types::BaseField

    def self.accepts(*types)
      @accepts ||= []
      @accepts += types
      @accepts
    end

    # All graphql fields exposing an id, should expose a global id.
    def id
      GitlabSchema.id_from_object(object)
    end

    def self.authorization
      @authorization ||= ::Gitlab::Graphql::Authorize::ObjectAuthorization.new(authorize)
    end

    def self.authorized?(object, context)
      return true unless Feature.enabled?(:graphql_framework_authorization)

      authorization.ok?(object, context[:current_user])
    end

    # Mutates the input array
    def self.remove_unauthorized(array, context)
      return unless Feature.enabled?(:graphql_framework_authorization)
      return unless array.is_a?(Array)
      return unless authorize.present?

      array
        .map! { |lazy| force(lazy) }
        .keep_if { |forced| authorized?(forced, context) }
    end

    def current_user
      context[:current_user]
    end

    def self.assignable?(object)
      assignable = accepts

      return true if assignable.blank?

      assignable.any? { |cls| object.is_a?(cls) }
    end

    def can?(ability, subject = object)
      Ability.allowed?(current_user, ability, subject)
    end
  end
end
