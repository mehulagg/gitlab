# frozen_string_literal: true

FactoryBot.define do
  factory :geo_lfs_object_registry_ssf, class: 'Geo::LfsObjectRegistrySsf' do
    association :lfs_object, factory: [:lfs_object, :with_file]
    state { Geo::LfsObjectRegistrySsf.state_value(:pending) }

    trait :synced do
      state { Geo::LfsObjectRegistrySsf.state_value(:synced) }
      last_synced_at { 5.days.ago }
    end

    trait :failed do
      state { Geo::LfsObjectRegistrySsf.state_value(:failed) }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :started do
      state { Geo::LfsObjectRegistrySsf.state_value(:started) }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
