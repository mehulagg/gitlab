# frozen_string_literal: true

FactoryBot.define do
  factory :external_approval_rule, class: 'ApprovalRules::ExternalApprovalRule' do
    project
    external_url { FFaker::Internet.http_url }

    sequence :name do |i|
      "rule #{i}"
    end
  end
end
