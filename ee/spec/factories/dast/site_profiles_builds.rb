# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_profiles_build, class: 'Dast::SiteProfilesBuild' do
    dast_site_profile

    ci_build { association :ci_build, project: dast_site_profile.project }
  end
end
