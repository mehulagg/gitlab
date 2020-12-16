# frozen_string_literal: true

FactoryBot.define do
  factory :epic_board, class: 'Boards::EpicBoard' do
    name
    group
  end
end
