# frozen_string_literal: true

FactoryBot.define do
  factory :geo_lfs_object_registry, class: 'Geo::LfsObjectRegistry' do
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
