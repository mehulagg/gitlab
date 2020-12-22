# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_profile do
    name { FFaker::Product.product_name }

    secret_key_iv { Base64.encode64(OpenSSL::Cipher.new('aes-256-cbc').random_iv) }

    before(:create) do |dast_site_profile|
      dast_site_profile.project ||= FactoryBot.create(:project)
      dast_site_profile.dast_site ||= FactoryBot.create(:dast_site, project: dast_site_profile.project)
    end
  end
end
