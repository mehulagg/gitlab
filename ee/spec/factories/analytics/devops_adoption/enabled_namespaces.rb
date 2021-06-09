# frozen_string_literal: true

FactoryBot.define do
  factory :devops_adoption_enabled_namespace, class: 'Analytics::DevopsAdoption::EnabledNamespace' do
    association :namespace, factory: :group
    association :display_namespace, factory: :group
  end
end
