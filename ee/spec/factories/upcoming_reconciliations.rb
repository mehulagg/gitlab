# frozen_string_literal: true

FactoryBot.define do
  factory :upcoming_reconciliation, class: 'GitlabSubscriptions::UpcomingReconciliation' do
    next_reconciliation_date { Date.current + 7.days }
    display_alert_from { Date.current.beginning_of_day }

    trait :self_managed do
      namespace { nil }
    end

    trait :saas do
      namespace
    end
  end
end
