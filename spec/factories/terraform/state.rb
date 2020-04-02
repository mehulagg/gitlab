# frozen_string_literal: true

FactoryBot.define do
  factory :terraform_state, class: 'Terraform::State' do
    project { create(:project) }

    sequence(:name) { |n| "state-#{n}.tfstate" }

    trait :with_file do
      file { fixture_file_upload('spec/fixtures/terraform/terraform.tfstate') }
    end
  end
end
