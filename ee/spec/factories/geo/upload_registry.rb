# frozen_string_literal: true

FactoryBot.define do
  factory :geo_upload_registry, class: 'Geo::UploadRegistry' do
    sequence(:file_id)
    file_type { :file }
    success { true }

    trait(:attachment) { file_type { :attachment } }
    trait(:avatar) { file_type { :avatar } }
    trait(:favicon) { file_type { :favicon } }
    trait(:file) { file_type { :file } }
    trait(:import_export) { file_type { :import_export } }
    trait(:issuable_metric_image) { file_type { :issuable_metric_image } }
    trait(:namespace_file) { file_type { :namespace_file } }
    trait(:personal_file) { file_type { :personal_file } }

    trait :failed do
      success { false }
      retry_count { 1 }
    end

    trait :never_synced do
      success { false }
      retry_count { nil }
    end

    trait :with_file do
      after(:build, :stub) do |registry, _|
        file =
          if registry.file_type.to_sym == :lfs
            raise NotImplementedError, 'Use create(:geo_lfs_object_registry, :with_lfs_object) instead'
          elsif registry.file_type.to_sym == :job_artifact
            raise NotImplementedError, 'Use create(:geo_job_artifact_registry, :with_artifact) instead'
          else
            create(:upload)
          end

        registry.file_id = file.id
      end
    end
  end
end
