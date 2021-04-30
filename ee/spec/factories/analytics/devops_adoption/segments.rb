# frozen_string_literal: true

FactoryBot.define do
  factory :devops_adoption_segment, class: 'Analytics::DevopsAdoption::Segment' do
    association :namespace, factory: :group
    association :display_namespace, factory: :group
  end
end
