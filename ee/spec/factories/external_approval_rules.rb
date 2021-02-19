# frozen_string_literal: true

FactoryBot.define do
  factory :external_approval_rule, class: 'ApprovalRules::ExternalApprovalRule' do
    project
    sequence :external_url do |i|
      "https://testurl.example.test#{i}"
    end

    sequence :name do |i|
      "rule #{i}"
    end
  end
end
