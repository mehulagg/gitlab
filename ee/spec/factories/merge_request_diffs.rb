# frozen_string_literal: true

FactoryBot.modify do
  factory :merge_request_diff do
    trait(:checksummed) do
      association :merge_request_diff_detail, :checksummed, strategy: :build
    end

    trait(:checksum_failure) do
      association :merge_request_diff_detail, :checksum_failure, strategy: :build
    end
  end
end
