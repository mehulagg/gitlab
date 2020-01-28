# frozen_string_literal: true

FactoryBot.define do
  factory :license_scanning_license, class: '::Gitlab::Ci::Reports::LicenseScanning::License' do
    initialize_with { new(id: id, name: name, url: url) }

    trait :mit do
      id { 'MIT' }
      name { 'MIT License' }
      url { 'https://opensource.org/licenses/MIT' }
    end

    trait :unknown do
      id { 'unknown' }
      name { 'Unknown' }
      url { '' }
    end
  end
end
