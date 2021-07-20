# frozen_string_literal: true

FactoryBot.modify do
  factory :upload do
    trait :issue_metric_image do
      model { association(:issuable_metric_image) }
      mount_point { :file }
      uploader { ::IssuableMetricImageUploader.name }
    end
  end
end
