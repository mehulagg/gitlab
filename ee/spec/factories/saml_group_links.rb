# frozen_string_literal: true

FactoryBot.define do
  sequence(:saml_group_name) { |n| "saml-group#{n}" }

  factory :saml_group_link do
    saml_group_name { generate(:saml_group_name) }
    access_level { Gitlab::Access::GUEST }
    group
  end
end
