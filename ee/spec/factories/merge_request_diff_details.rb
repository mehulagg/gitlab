# frozen_string_literal: true

FactoryBot.define do
  factory :merge_request_diff_detail do
    merge_request_diff

    trait(:checksummed) do
      verification_checksum { 'abc' }
    end

    trait(:checksum_failure) do
      verification_failure { 'Could not calculate the checksum' }
    end
  end
end
