# frozen_string_literal: true

FactoryBot.define do
  factory :approver_group do
    target factory: :merge_request
    group
  end
end
