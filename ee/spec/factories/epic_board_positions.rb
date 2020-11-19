# frozen_string_literal: true

FactoryBot.define do
  factory :epic_board_position do
    epic
    board
    relative_position { RelativePositioning::START_POSITION }
  end
end
