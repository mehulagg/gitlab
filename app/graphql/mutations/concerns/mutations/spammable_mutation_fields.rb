# frozen_string_literal: true

module Mutations
  module SpammableMutationFields
    extend ActiveSupport::Concern

    included do
      field :spam,
            GraphQL::BOOLEAN_TYPE,
            null: true,
            description: 'Indicates whether the operation returns a snippet detected as spam'
    end

    def with_spam_params(&block)
      yield({ api: true, request: context[:request] })
    end
  end
end
