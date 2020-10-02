# frozen_string_literal: true

FactoryBot.define do
  factory :incident_sla, class: 'IncidentManagement::IncidentSla' do
    issue
    due_at { 1.hour.from_now }
  end
end
