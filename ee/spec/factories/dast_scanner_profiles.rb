# frozen_string_literal: true

FactoryBot.define do
  factory :dast_scanner_profile do
    name { FFaker::Product.product_name }

    before(:create) do |dast_scanner_profile|
      dast_scanner_profile.project ||= FactoryBot.create(:project)
    end
  end
end
