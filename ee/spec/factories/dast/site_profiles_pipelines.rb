# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_profiles_pipeline, class: 'Dast::SiteProfilesPipeline' do
    dast_site_profile

    ci_pipeline { association :ci_pipeline, project: dast_site_profile.project }
  end
end
