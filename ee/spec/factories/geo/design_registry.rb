# frozen_string_literal: true

FactoryBot.define do
  factory :geo_design_registry, class: 'Geo::DesignRegistry' do
    project
    last_sync_failure { nil }
    last_synced_at { nil }
    state { :pending }

    after(:create) do |registry|
      issue = create(:issue, project: registry.project)
      create(:design, project: registry.project, issue: issue)
    end

    trait :synced do
      state { :synced }
      last_synced_at { 5.days.ago }
    end

    trait :sync_failed do
      state { :failed }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :sync_started do
      state { :started }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
