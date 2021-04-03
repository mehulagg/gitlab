# frozen_string_literal: true

FactoryBot.define do
  factory :epic_list, class: 'Boards::EpicList' do
    epic_board
    association :label, factory: :group_label
    list_type { :label }
    sequence(:position)
  end
end
