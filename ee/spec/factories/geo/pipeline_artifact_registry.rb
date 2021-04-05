# frozen_string_literal: true

FactoryBot.define do
  factory :geo_pipeline_artifact_registry, class: 'Geo::PipelineArtifactRegistry' do
    pipeline_artifact factory: :ci_pipeline_artifact
    state { Geo::PipelineArtifactRegistry.state_value(:pending) }

    trait :synced do
      state { Geo::PipelineArtifactRegistry.state_value(:synced) }
      last_synced_at { 5.days.ago }
    end

    trait :failed do
      state { Geo::PipelineArtifactRegistry.state_value(:failed) }
      last_synced_at { 1.day.ago }
      retry_count { 2 }
      last_sync_failure { 'Random error' }
    end

    trait :started do
      state { Geo::PipelineArtifactRegistry.state_value(:started) }
      last_synced_at { 1.day.ago }
      retry_count { 0 }
    end
  end
end
