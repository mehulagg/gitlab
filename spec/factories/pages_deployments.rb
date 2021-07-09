# frozen_string_literal: true

FactoryBot.define do
  factory :pages_deployment, class: 'PagesDeployment' do
    project

    transient do
      filename { nil }
    end

    trait(:migrated) do
      filename { PagesDeployment::MIGRATED_FILE_NAME }
    end

    trait(:verification_succeeded) do
      with_file
      verification_checksum { 'abc' }
      verification_state { PagesDeployment.verification_state_value(:verification_succeeded) }
    end

    trait(:verification_failed) do
      with_file
      verification_failure { 'Could not calculate the checksum' }
      verification_state { PagesDeployment.verification_state_value(:verification_failed) }
    end

    after(:build) do |deployment, evaluator|
      file = UploadedFile.new("spec/fixtures/pages.zip", filename: evaluator.filename)

      deployment.file = file
      deployment.file_sha256 = Digest::SHA256.file(file.path).hexdigest
      ::Zip::File.open(file.path) do |zip_archive|
        deployment.file_count = zip_archive.count
      end
    end
  end
end
