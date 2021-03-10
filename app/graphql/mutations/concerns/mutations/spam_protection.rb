# frozen_string_literal: true

module Mutations
  # This concern can be mixed into a mutation to provide support for spam checking,
  # and optionally support the workflow to allow clients to display and solve CAPTCHAs.
  module SpamProtection
    extend ActiveSupport::Concern
    include Spam::Concerns::HasSpamActionResponseFields

    SpamActionError = Class.new(GraphQL::ExecutionError)
    NeedsCaptchaResponseError = Class.new(SpamActionError)
    SpamDisallowedError = Class.new(SpamActionError)

    NEEDS_CAPTCHA_RESPONSE_MESSAGE = "Request has been denied: Solve CAPTCHA challenge and retry"
    SPAM_DISALLOWED_MESSAGE = "Request has been denied: SPAM detected"

    private

    # additional_spam_params    -> hash
    #
    # Used from a spammable mutation's #resolve method to generate
    # the required additional spam/CAPTCHA params which must be merged into the params
    # passed to the constructor of a service, where they can then be used in the service
    # to perform spam checking via SpamActionService.
    #
    # Also accesses the #context of the mutation's Resolver superclass to obtain the request.
    #
    # Example:
    #
    # existing_args.merge!(additional_spam_params)
    def additional_spam_params
      {
        api: true,
        request: context[:request]
      }
    end

    def spam_action_response(object)
      fields = spam_action_response_fields(object)
      kind = if fields[:needs_captcha_response]
               :needs_captcha_response
             elsif fields[:spam]
               :spam
             end

      [kind, fields]
    end

    def check_spam_action_response!(object)
      kind, fields = spam_action_response(object)

      case kind
      when :needs_captcha_response
        delete fields[:spam]
        raise NeedsCaptchaResponseError.new(NEEDS_CAPTCHA_RESPONSE_MESSAGE, extensions: fields)
      when :spam
        raise SpamDisallowedError.new(SPAM_DISALLOWED_MESSAGE, extensions: { spam: true })
      else
        nil
      end
    end
  end
end
