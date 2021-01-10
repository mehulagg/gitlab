# frozen_string_literal: true

module Mutations
  # This concern can be mixed into a mutation to provide support for spam checking,
  # and optionally support the workflow to allow clients to display and solve recaptchas.
  module CanMutateSpammable
    extend ActiveSupport::Concern

    # NOTE: The arguments and fields are intentionally named with 'captcha' instead of 'recaptcha',
    # so that they can be applied to future alternative captcha implementations other than
    # reCAPTCHA (e.g. FriendlyCaptcha) without having to change the names and descriptions in the API.
    included do
      argument :captcha_response, GraphQL::STRING_TYPE,
               required: false,
               description: 'A valid captcha response value obtained by using the provided captchaSiteKey with a captcha API to present a challenge to be solved on the client.'

      argument :spam_log_id, GraphQL::INT_TYPE,
               required: false,
               description: 'The spam log ID which must be returned along with a valid captcha response in order for the operation to be completed.'

      field :spam,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates that the operation was detected as definite spam. There is no option to resubmit the request with a captcha response.'

      field :needs_captcha_response,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates that the operation was detected as possible spam and not completed. If captcha is enabled, the request must be resubmitted with a valid captcha response and spam_log_id included in order for the operation to be completed.'

      field :spam_log_id,
            GraphQL::INT_TYPE,
            null: true,
            description: 'The spam log ID which must be returned along with a valid captcha response in order for the operation to be completed.'

      field :captcha_site_key,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'The captcha site key which must be used to render a challenge for the user to solve in order to obtain a valid captchaResponse value.'
    end

    private

    # additional_spam_params    -> hash
    #
    # Used from a spammable mutation's #resolve method to generate
    # the required additional spam/recaptcha params which must be merged into the params
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

    # with_spam_action_fields(spammable) { {other_fields: true} }    -> hash
    #
    # Takes a Spammable and a block as arguments.
    #
    # The block passed should be a hash, which the spam action fields will be merged into.
    def with_spam_action_fields(spammable)
      spam_action_fields = {
        spam: spammable.spam?,
        # NOTE: These fields are intentionally named with 'captcha' instead of 'recaptcha', so
        # that they can be applied to future alternative captcha implementations other than
        # reCAPTCHA (such as FriendlyCaptcha) without having to change the response field name
        # in the API.
        needs_captcha_response: spammable.render_recaptcha?,
        spam_log_id: spammable.spam_log&.id,
        captcha_site_key: Gitlab::CurrentSettings.recaptcha_site_key
      }

      yield.merge(spam_action_fields)
    end
  end
end
