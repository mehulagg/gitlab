# frozen_string_literal: true

FactoryBot.define do
  factory :external_approval, class: 'ApprovalRules::ExternalApproval' do
    merge_request
    external_approval_rule
  end
end
