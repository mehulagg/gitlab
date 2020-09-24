# frozen_string_literal: true

module Subscriptions
  class BaseSubscription < GraphQL::Schema::Subscription
    object_class Types::BaseObject
    field_class Types::BaseField

    def initialize(object:, context:, field:)
      super

      # Reset user so that we don't use a stale user for authorization
      context[:current_user].reset if context[:current_user]
    end
  end
end
