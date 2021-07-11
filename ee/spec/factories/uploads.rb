# frozen_string_literal: true

FactoryBot.modify do
  factory :upload do
    trait :issue_metric_image do
      model { association(:issuable_metric_image) }
      mount_point { :file }
      uploader { ::IssuableMetricImageUploader.name }
    end

    trait(:verification_succeeded) do
      with_file
      verification_checksum { 'abc' }
      verification_state { CoolWidget.verification_state_value(:verification_succeeded) }
    end

    trait(:verification_failed) do
      with_file
      verification_failure { 'Could not calculate the checksum' }
      verification_state { CoolWidget.verification_state_value(:verification_failed) }
    end
  end
end
