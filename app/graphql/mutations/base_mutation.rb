# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    include Gitlab::Graphql::Authorize::AuthorizeResource
    prepend Gitlab::Graphql::CopyFieldDescription
    prepend ::Gitlab::Graphql::GlobalIDCompatibility

    ERROR_MESSAGE = 'You cannot perform write operations on a read-only instance'

    field_class ::Types::BaseField
    argument_class ::Types::BaseArgument

    field :errors, [GraphQL::STRING_TYPE],
          null: false,
          description: 'Errors encountered during execution of the mutation.'

    def current_user
      context[:current_user]
    end

    def api_user?
      context[:is_sessionless_user]
    end

    # Returns Array of errors on an ActiveRecord object
    def errors_on_object(record)
      record.errors.full_messages
    end

    def ready?(**args)
      raise_resource_not_available_error! ERROR_MESSAGE if Gitlab::Database.read_only?

      true
    end

    def load_application_object(argument, lookup_as_type, id, context)
      ::Gitlab::Graphql::Lazy.new { super }.catch(::GraphQL::UnauthorizedError) do |e|
        Gitlab::ErrorTracking.track_exception(e)
        # The default behaviour is to abort processing and return nil for the
        # entire mutation field, but not set any top-level errors. We prefer to
        # at least say that something went wrong.
        raise_resource_not_available_error!
      end
    end

    def self.authorized?(object, context)
      return context[:api_scopes].include?('api') if context[:is_sessionless_user]

      Ability.allowed?(context[:current_user], :execute_graphql_mutation)
    end

    # See: AuthorizeResource#authorized_resource?
    def self.authorization
      @authorization ||= ::Gitlab::Graphql::Authorize::ObjectAuthorization.new(authorize)
    end
  end
end
