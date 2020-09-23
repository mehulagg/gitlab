# frozen_string_literal: true

FactoryBot.define do
  factory :geo_merge_request_diff_registry, class: 'Geo::MergeRequestDiffRegistry' do
    association :merge_request_diff, factory: :external_merge_request_diff

    state { Geo::MergeRequestDiffRegistry.state_value(:pending) }

    trait :synced do
      state { Geo::MergeRequestDiffRegistry.state_value(:synced) }
      last_synced_at { 5.days.ago }
    end

    trait :failed do
      state { Geo::MergeRequestDiffRegistry.state_value(:failed) }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :started do
      state { Geo::MergeRequestDiffRegistry.state_value(:started) }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
