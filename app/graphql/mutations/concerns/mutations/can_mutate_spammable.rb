# frozen_string_literal: true

module Mutations
  # This concern can be mixed into a mutation to provide support for spam checking,
  # and optionally support the workflow to allow clients to display and solve recaptchas.
  module CanMutateSpammable
    extend ActiveSupport::Concern

    included do
      argument :recaptcha_response, GraphQL::STRING_TYPE,
               required: false,
               description: 'A valid recaptchaResponse value obtained by using the provided recaptchaSiteKey with the reCAPTCHA API to present a challenge for the user to solve. See the reCAPTCHA API documentation for more details.'

      argument :spam_log_id, GraphQL::INT_TYPE,
               required: false,
               description: 'The spam log ID which must be returned along with a valid recaptchaResponse in order for the operation to be completed.'

      field :spam,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether the operation returns a record detected as spam.'

      field :needs_recaptcha_response,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates that a valid recaptchaResponse field must be included in the request in order for the operation to be completed. The recaptchaResponse value is obtained by using the provided recaptchaSiteKey with the reCAPTCHA API to present a challenge for the user to solve. See the reCAPTCHA API documentation for more details.'

      field :spam_log_id,
            GraphQL::INT_TYPE,
            null: true,
            description: 'The spam log ID which must be returned along with a valid recaptchaResponse in order for the operation to be completed.'

      field :recaptcha_site_key,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'The reCAPTCHA site_key which must be used to render a challenge for the user to solve in order to obtain a valid recaptchaResponse value.'
    end

    # additional_spam_check_params(resolve_args)    -> hash
    #
    # Takes the args parameter from the mutation's #resolve method, and returns
    # the required additional spam/recaptcha params which must be merged into the params
    # passed to the constructor of a service, where they can then be used in the service
    # via SpamCheckMethods#filter_spam_check_params, SpamCheckMethods#spam_check, and
    # SpamCheckMethods#verify_spammable_recaptcha!
    #
    # Also accesses the #context of the mutation's Resolver superclass to obtain the request.
    #
    # Example:
    #
    # existing_args.merge!(additional_spam_check_params(args))
    def additional_spam_check_params(resolve_args)
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
