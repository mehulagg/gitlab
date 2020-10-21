# frozen_string_literal: true

FactoryBot.define do
  factory :saml_group_link do
    sequence(:saml_group_name) { |n| "saml-group#{n}" }
    access_level { Gitlab::Access::GUEST }
    group
  end
end
