# frozen_string_literal: true

FactoryBot.define do
  factory :dora_daily_metrics, class: 'Dora::DailyMetrics' do
    environment
    date { Time.current.to_date }
  end
end
