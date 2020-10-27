# frozen_string_literal: true

FactoryBot.define do
  factory :resource_weight_event do
    issue { association(:issue) }
    user { issue&.author || association(:user) }
  end
end
