# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_participant, class: 'IncidentManagement::OncallParticipant' do
    association :rotation, factory: :incident_management_oncall_rotation
    association :user, factory: :user
    color_palette { IncidentManagement::OncallParticipant.color_palettes.first.first }
    color_weight { IncidentManagement::OncallParticipant.color_weights.first.first }
  end
end
