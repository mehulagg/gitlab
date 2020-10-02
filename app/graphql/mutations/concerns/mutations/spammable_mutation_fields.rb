# frozen_string_literal: true

module Mutations
  module SpammableMutationFields
    extend ActiveSupport::Concern

    included do
      field :spam,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether the operation returns a snippet detected as spam'

      field :needs_recaptcha,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether the operation returns a snippet that needs the recaptcha'
    end

    def with_spam_params(&block)
      yield.merge({ api: true, request: context[:request] })
    end

    def with_spam_fields(spammable, &block)
      { spam: spam?(spammable), needs_recaptcha: needs_recaptcha?(spammable) }.merge!(yield)
    end

    def spam?(spammable)
      spammable.spam? && only_spammable_error?(spammable)
    end

    def needs_recaptcha?(spammable)
      spammable.needs_recaptcha? && Gitlab::Recaptcha.enabled? && only_spammable_error?(spammable)
    end

    private

    def only_spammable_error?(spammable)
      spammable.errors.count <= 1
    end
  end
end
