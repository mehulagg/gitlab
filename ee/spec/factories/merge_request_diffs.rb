# frozen_string_literal: true

FactoryBot.modify do
  factory :merge_request_diff do
    trait(:checksummed) do
      association :merge_request_diff_detail, :checksummed, strategy: :build
    end

    trait(:checksum_failure) do
      association :merge_request_diff_detail, :checksum_failure, strategy: :build
    end

    trait(:verification_succeeded) do
      with_file
      verification_checksum { 'abc' }
      verification_state { ::MergeRequestDiff.verification_state_value(:verification_succeeded) }
    end

    trait(:verification_failed) do
      with_file
      verification_failure { 'Could not calculate the checksum' }
      verification_state { ::MergeRequestDiff.verification_state_value(:verification_failed) }
    end
  end
end
