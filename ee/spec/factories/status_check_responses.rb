# frozen_string_literal: true

FactoryBot.define do
  factory :status_check_response, class: 'MergeRequests::StatusCheckResponse' do
    merge_request
    external_approval_rule
  end
end
