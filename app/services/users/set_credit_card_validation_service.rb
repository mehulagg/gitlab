# frozen_string_literal: true

module Users
  class SetCreditCardValidationService < BaseService
    def initialize(params = {})
      @params = params.to_h.dup.with_indifferent_access
    end

    def execute
      if ::Users::CreditCardValidation.upsert(@params)
        ServiceResponse.success(message: 'CreditCardValidation was set')
      else
        ServiceResponse.error(message: 'Could not set CreditCardValidation')
      end
    end
  end
end
