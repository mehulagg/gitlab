# frozen_string_literal: true
FactoryBot.define do
  factory :scim_identity do
    extern_uid { generate(:username) }
    group
    user
    active { true }
  end
end
