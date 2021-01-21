# frozen_string_literal: true

FactoryBot.define do
  factory :geo_package_file_registry, class: 'Geo::PackageFileRegistry' do
    association :package_file, factory: [:package_file, :npm]
    state { Geo::PackageFileRegistry.state_value(:pending) }

    trait :synced do
      state { Geo::PackageFileRegistry.state_value(:synced) }
      last_synced_at { 5.days.ago }
    end

    trait :failed do
      state { Geo::PackageFileRegistry.state_value(:failed) }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :started do
      state { Geo::PackageFileRegistry.state_value(:started) }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
