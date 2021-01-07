# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site do
    project

    url { generate(:url) }

    trait :with_dast_site_validation do
      dast_site_validation do
        association(:dast_site_validation, dast_site_token: association(:dast_site_token, project: project))
      end
    end
  end
end
