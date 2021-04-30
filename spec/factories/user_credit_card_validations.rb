# frozen_string_literal: true

FactoryBot.define do
  factory :user_credit_card_validation do
    user

    credit_card_validated_at { Time.current }
  end
end
