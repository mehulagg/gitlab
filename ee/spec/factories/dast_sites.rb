# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site do
    url { generate(:url) }

    before(:create) do |dast_site|
      dast_site.project ||= FactoryBot.create(:project)
      dast_site.dast_site_validation ||= FactoryBot.create(
        :dast_site_validation,
        dast_site_token: FactoryBot.create(
          :dast_site_token,
          project: dast_site.project
        )
      )
    end
  end
end
