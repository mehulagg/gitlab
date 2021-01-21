# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_profile do
    project

    dast_site { association :dast_site, project: project }

    sequence :name do |i|
      "#{FFaker::Product.product_name.truncate(200)} - #{i}"
    end

    trait :with_dast_site_validation do
      dast_site { association :dast_site, :with_dast_site_validation, project: project }
    end
  end
end
