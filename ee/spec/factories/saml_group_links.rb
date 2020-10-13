# frozen_string_literal: true

FactoryBot.define do
  factory :saml_group_link do
    group_name { 'group1' }
    access_level { Gitlab::Access::GUEST }
    group
  end
end
