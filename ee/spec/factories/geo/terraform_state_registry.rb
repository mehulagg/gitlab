# frozen_string_literal: true

FactoryBot.define do
  factory :geo_terraform_state_registry, class: 'Geo::TerraformStateRegistry' do
    association :terraform_state, factory: :terraform_state
    state { Geo::TerraformStateRegistry.state_value(:pending) }

    trait :synced do
      state { Geo::TerraformStateRegistry.state_value(:synced) }
      last_synced_at { 5.days.ago }
    end

    trait :failed do
      state { Geo::TerraformStateRegistry.state_value(:failed) }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :started do
      state { Geo::TerraformStateRegistry.state_value(:started) }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
