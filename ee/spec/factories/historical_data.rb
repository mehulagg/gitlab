# frozen_string_literal: true

FactoryBot.define do
  factory :historical_data do
    recorded_at { Time.current }
    active_user_count { 1 }
  end
end
