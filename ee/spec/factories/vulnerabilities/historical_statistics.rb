# frozen_string_literal: true

FactoryBot.define do
  factory :vulnerability_historical_statistic, class: 'Vulnerabilities::HistoricalStatistic' do
    project
    letter_grade { 'a' }
    date { Date.current }
  end
end
