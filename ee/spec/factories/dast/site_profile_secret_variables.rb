# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_profile_secret_variable, class: 'Dast::SiteProfileSecretVariable' do
    dast_site_profile

    sequence(:key) { |n| "VARIABLE_#{n}" }
    raw_value { 'VARIABLE_VALUE' }
  end
end
