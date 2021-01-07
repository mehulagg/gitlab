# frozen_string_literal: true

FactoryBot.define do
  factory :epic_list, class: 'Boards::EpicList' do
    epic_board
    label
    list_type { :label }
    sequence(:position)
  end
end
