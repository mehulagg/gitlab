# frozen_string_literal: true

module Users
  class SetCreditCardValidationService < BaseService
    def initialize(params)
      @params = params.to_h.dup.with_indifferent_access
    end

    def execute
      ::Users::CreditCardValidation.upsert(@params)

      ServiceResponse.success(message: 'CreditCardValidation was set')
    rescue StandardError => e
      ServiceResponse.error(message: 'Could not set CreditCardValidation: #{e.messages}')
    end
  end
end
