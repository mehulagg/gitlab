# frozen_string_literal: true

FactoryBot.define do
  factory :epic_user_preference, class: 'Boards::EpicUserPreference' do
    board
    user
    epic
  end
end
