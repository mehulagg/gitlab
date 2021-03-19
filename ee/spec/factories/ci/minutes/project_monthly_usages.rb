# frozen_string_literal: true

FactoryBot.define do
  factory :ci_project_monthly_usage, class: 'Ci::Minutes::ProjectMonthlyUsage' do
    amount_used { 100 }
    project factory: :project
    date { Time.current.utc.beginning_of_month }
  end
end
