# frozen_string_literal: true

FactoryBot.define do
  factory :epic_issue do
    epic
    issue
    relative_position { RelativePositioning::START_POSITION }
  end
end
