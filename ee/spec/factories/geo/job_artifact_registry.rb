# frozen_string_literal: true

FactoryBot.define do
  factory :geo_job_artifact_registry, class: 'Geo::JobArtifactRegistry' do
    sequence(:artifact_id)
    success { true }

    trait :failed do
      success { false }
      retry_count { 1 }
    end

    trait :never_synced do
      success { false }
      retry_count { nil }
    end

    trait :with_artifact do
      transient do
        artifact_type { nil } # e.g. :archive, :metadata, :trace ...
      end

      after(:build, :stub) do |registry, evaluator|
        file = create(:ci_job_artifact, evaluator.artifact_type)
        registry.artifact_id = file.id
      end
    end

    trait :orphan do
      with_artifact
      after(:create) do |registry, _|
        Ci::JobArtifact.find(registry.artifact_id).delete
      end
    end
  end
end
