# frozen_string_literal: true

FactoryBot.modify do
  factory :credit_card_validation do
    user
    credit_card_validated_at { Time.current }
  end
end
