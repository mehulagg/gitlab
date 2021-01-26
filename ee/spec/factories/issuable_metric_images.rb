# frozen_string_literal: true

FactoryBot.define do
  factory :issuable_metric_image, class: 'IssuableMetricImage' do
    association :issue, factory: :incident
    url { generate(:url) }

    trait :local do
      file_store { ObjectStorage::Store::LOCAL }
    end

    after(:build) do |issuable_metric_image|
      issuable_metric_image.file = fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg')
    end
  end
end
