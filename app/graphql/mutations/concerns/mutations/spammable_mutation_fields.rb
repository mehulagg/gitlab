# frozen_string_literal: true

module Mutations
  module SpammableMutationFields
    extend ActiveSupport::Concern

    included do
      field :spam,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether the operation returns a record detected as spam'

      field :needs_recaptcha,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether a valid gRecaptchaResponse response to a reCAPTCHA challenge must be included in the request in order for the operation to be completed'

      field :spam_log_id,
            GraphQL::INT_TYPE,
            null: true,
            description: 'The spam log ID which must be returned along with a valid gRecaptcha response in order for the operation to be completed'
    end

    def with_spam_params(&block)
      request = Feature.enabled?(:snippet_spam) ? context[:request] : nil

      yield.merge({ api: true, request: request })
    end

    def with_spam_fields(spammable, &block)
      {
        spam: spammable.spam?,
        needs_recaptcha: needs_recaptcha?(spammable),
        spam_log_id: spam_log_id(spammable)
      }.merge!(yield)
    end

    private

    def needs_recaptcha?(spammable)
      spammable.needs_recaptcha? && Gitlab::Recaptcha.enabled? && spammable.errors.count <= 1
    end

    def spam_log_id(spammable)
      spammable.spam_log.id if needs_recaptcha?(spammable)
    end
  end
end
