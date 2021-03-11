# frozen_string_literal: true

FactoryBot.define do
  factory :epic_board, class: 'Boards::EpicBoard' do
    name
    group

    after(:create) do |board|
      board.lists.create!(list_type: :closed)
    end
  end
end
