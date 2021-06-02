# frozen_string_literal: true

FactoryBot.define do
  # sm = self managed GitLab instance
  factory :sm_upcoming_reconciliation, class: 'UpcomingReconciliation' do
    next_reconciliation_date { Date.current + 7.days }
    display_alert_from { Date.current.beginning_of_day }

    factory :saas_upcoming_reconciliation do
      namespace
    end
  end
end
