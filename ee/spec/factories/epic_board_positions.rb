# frozen_string_literal: true

FactoryBot.define do
  factory :epic_board_position, class: 'Boards::EpicBoardPosition' do
    epic
    epic_board
    relative_position { RelativePositioning::START_POSITION }
  end
end
