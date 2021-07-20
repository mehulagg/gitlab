# frozen_string_literal: true

FactoryBot.define do
  factory :incident_management_oncall_participant, class: 'IncidentManagement::OncallParticipant' do
    association :rotation, factory: :incident_management_oncall_rotation
    association :user, factory: :user
    color_palette { IncidentManagement::OncallParticipant.color_palettes.first.first }
    color_weight { IncidentManagement::OncallParticipant.color_weights.first.first }

    trait :with_developer_access do
      after(:build) do |participant, _|
        participant.rotation.project.add_developer(participant.user)
      end
    end

    trait :removed do
      is_removed { true }
    end

    trait :utc do
      association :rotation, :utc, factory: :incident_management_oncall_rotation
    end
  end
end
