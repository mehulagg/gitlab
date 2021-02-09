# frozen_string_literal: true

FactoryBot.define do
  factory :geo_secondary_usage_data, class: 'Geo::SecondaryUsageData' do
    git_fetch_event_count { rand(100000) }
  end
end
