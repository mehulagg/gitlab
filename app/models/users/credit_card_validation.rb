# frozen_string_literal: true

module Users
  class CreditCardValidation < ApplicationRecord
    RELEASE_DAY = Date.new(2021, 5, 17)

    self.table_name = 'user_credit_card_validations'

    belongs_to :user

    def credit_card_validated_at=(val)
      super unless val == '1' || val == '0'

      if val == '1' && !persisted?
        super(Time.zone.now)
      elsif val == '0' && persisted?
        self.destroy
      end
    end
  end
end
