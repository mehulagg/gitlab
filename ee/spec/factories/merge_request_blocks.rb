# frozen_string_literal: true

FactoryBot.define do
  factory :merge_request_block do
    blocking_merge_request { association(:merge_request) }
    blocked_merge_request { association(:merge_request) }
  end
end
