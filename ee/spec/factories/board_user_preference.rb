# frozen_string_literal: true

FactoryBot.define do
  factory :board_user_preference do
    user
    board
  end
end
