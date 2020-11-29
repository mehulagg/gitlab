# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_schedule, class: 'IncidentManagement::OncallSchedule' do
    project
    name { 'Default On-call Schedule' }
    description { 'On-call description' }
    timezone { 'Europe/Berlin' }
  end
end
