# frozen_string_literal: true

module Subscriptions
  class BaseSubscription < GraphQL::Schema::Subscription
    object_class Types::BaseObject
    field_class Types::BaseField

    def initialize(object:, context:, field:)
      super

      # Reset user so that we don't use a stale user for authorization
      current_user.reset if current_user
    end

    def authorized?(*)
      raise NotImplementedError
    end

    private

    def current_user
      context[:current_user]
    end
  end
end
