# frozen_string_literal: true

FactoryBot.define do
  factory :software_license, class: 'SoftwareLicense' do
    sequence(:name) { |n| "SOFTWARE-LICENSE-2.7/example_#{n}" }

    trait :mit do
      spdx_identifier { 'MIT' }
      name { 'MIT' }
    end

    trait :apache_2_0 do
      spdx_identifier { 'Apache-2.0' }
      name { 'Apache 2.0 License' }
    end

    trait :user_entered do
      spdx_identifier { nil }
    end
  end
end
