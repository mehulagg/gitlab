# frozen_string_literal: true

FactoryBot.define do
  factory :geo_lfs_object_legacy_registry, class: 'Geo::LfsObjectRegistry' do
    sequence(:lfs_object_id)
    success { true }

    trait :failed do
      success { false }
      retry_count { 1 }
    end

    trait :never_synced do
      success { false }
      retry_count { nil }
    end

    trait :with_lfs_object do
      after(:build, :stub) do |registry, _|
        lfs_object = create(:lfs_object)
        registry.lfs_object_id = lfs_object.id
      end
    end
  end
end

FactoryBot.define do
  factory :geo_lfs_object_registry, class: 'Geo::LfsObjectRegistry' do
    lfs_object
    state { Geo::LfsObjectRegistry.state_value(:pending) }

    trait :synced do
      state { Geo::LfsObjectRegistry.state_value(:synced) }
      last_synced_at { 5.days.ago }
    end

    trait :failed do
      state { Geo::LfsObjectRegistry.state_value(:failed) }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :started do
      state { Geo::LfsObjectRegistry.state_value(:started) }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
