# frozen_string_literal: true

FactoryBot.define do
  factory :dast_scanner_profiles_build, class: 'Dast::ScannerProfilesBuild' do
    dast_scanner_profile

    ci_build { association :ci_build, project: dast_scanner_profile.project }
  end
end
