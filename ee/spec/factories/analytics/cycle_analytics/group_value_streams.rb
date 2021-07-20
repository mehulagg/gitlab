# frozen_string_literal: true

FactoryBot.define do
  factory :cycle_analytics_group_value_stream, class: 'Analytics::CycleAnalytics::GroupValueStream' do
    sequence(:name) { |n| "Value Stream ##{n}" }

    group
  end
end
