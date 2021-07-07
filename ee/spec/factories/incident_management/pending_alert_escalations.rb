# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_pending_alert_escalation, class: 'IncidentManagement::PendingEscalations::Alert' do
    transient do
      project { create(:project) } # rubocop:disable FactoryBot/InlineAssociation
    end

    rule { association :incident_management_escalation_rule, project: project }
    alert { association :alert_management_alert, project: project }
    process_at { 5.minutes.from_now }
  end
end
