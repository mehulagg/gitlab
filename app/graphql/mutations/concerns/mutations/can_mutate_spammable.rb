# frozen_string_literal: true

module Mutations
  # This concern can be mixed into a mutation to provide support for spam checking,
  # and optionally support the workflow to allow clients to display and solve recaptchas.
  module CanMutateSpammable
    extend ActiveSupport::Concern

    included do
      field :spam,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether the operation returns a record detected as spam.'
    end

    # additional_spam_check_params    -> hash
    #
    # Used from a spammable mutation's #resolve method to generate
    # the required additional spam/recaptcha params which must be merged into the params
    # passed to the constructor of a service, where they can then be used in the service
    # via SpamCheckMethods#filter_spam_check_params, SpamCheckMethods#spam_check, and
    # SpamCheckMethods#verify_spammable_recaptcha!
    #
    # Also accesses the #context of the mutation's Resolver superclass to obtain the request.
    #
    # Example:
    #
    # existing_args.merge!(additional_spam_check_params())
    def additional_spam_check_params
      {
        api: true,
        request: context[:request]
      }
    end

    # with_spam_check_fields(payload) { {other_params: true} }    -> hash
    #
    # Takes a ServiceResponse payload as an argument, which may contain
    # a :spam_check_fields entry.
    #
    # The block passed should be a hash, which the spam_check_fields,
    # if they exist, will be merged into
    def with_spam_check_fields(payload, &block)
      spam_check_fields = payload.fetch(:spam_check_fields, {})
      yield.merge(spam_check_fields)
    end
  end
end
