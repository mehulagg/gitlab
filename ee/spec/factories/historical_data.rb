# frozen_string_literal: true

FactoryBot.define do
  factory :historical_data do
    date { Date.today }
    active_user_count { 1 }
  end
end
