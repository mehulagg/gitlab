# frozen_string_literal: true

FactoryBot.define do
  factory :epic_board_recent_visit, class: 'Boards::EpicBoardRecentVisit' do
    user
    group
    epic_board
  end
end
