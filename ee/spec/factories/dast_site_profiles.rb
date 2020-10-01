# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_profile do
    name { FFaker::Product.product_name }

    before(:create) do |dast_site_profile|
      dast_site_profile.project ||= FactoryBot.create(:project)
      dast_site_profile.dast_site ||= FactoryBot.create(
        :dast_site,
        project: dast_site_profile.project,
        dast_site_validation: FactoryBot.create(
          :dast_site_validation,
          dast_site_token: FactoryBot.create(
            :dast_site_token,
            project: dast_site_profile.project
          )
        )
      )
    end
  end
end
