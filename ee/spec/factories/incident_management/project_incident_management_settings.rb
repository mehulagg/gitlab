# frozen_string_literal: true

FactoryBot.modify do
  factory :project_incident_management_setting, class: 'IncidentManagement::ProjectIncidentManagementSetting' do
    sla_timer { false }
    sla_timer_minutes { nil }

    trait :sla_enabled do
      sla_timer { true }
      sla_timer_minutes { 15 }
    end
  end
end
