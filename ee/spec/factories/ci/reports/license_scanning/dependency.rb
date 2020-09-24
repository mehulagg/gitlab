# frozen_string_literal: true

FactoryBot.define do
  factory :license_scanning_dependency, class: '::Gitlab::Ci::Reports::LicenseScanning::Dependency' do
    initialize_with { new(name, path: path) }

    trait :rails do
      name { 'rails' }
      path { '.' }
    end
  end
end
