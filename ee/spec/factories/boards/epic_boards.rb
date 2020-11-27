# frozen_string_literal: true

FactoryBot.define do
  factory :epic_board, class: 'Boards::EpicBoard' do
    sequence(:name) { |n| "board#{n}" }
    group
  end
end
