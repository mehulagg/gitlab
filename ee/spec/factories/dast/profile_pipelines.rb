# frozen_string_literal: true

FactoryBot.define do
  factory :dast_profile_pipeline, class: 'Dast::ProfilePipeline' do
    profile { association :dast_profile }
    pipeline { association :ci_pipeline, project: profile.project }
  end
end
