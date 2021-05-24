# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_alert_escalation, class: 'IncidentManagement::AlertEscalation' do
    association :policy, factory: :incident_management_escalation_policy
    association :alert, factory: :alert_management_alert
  end
end
