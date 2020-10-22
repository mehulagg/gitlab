# frozen_string_literal: true
FactoryBot.define do
  factory :group_saml_identity, class: 'Identity', parent: :identity do
    provider { 'group_saml' }
    extern_uid { generate(:username) }
    saml_provider
    user
  end

  trait :group_owner do
    after(:create) do |identity, evaluator|
      identity.saml_provider.group.add_owner(identity.user)
    end
  end
end
