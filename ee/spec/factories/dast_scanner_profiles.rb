# frozen_string_literal: true

FactoryBot.define do
  factory :dast_scanner_profile do
    sequence :name do |i|
      "#{FFaker::Product.product_name.truncate(200)} - #{i}"
    end

    before(:create) do |dast_scanner_profile|
      dast_scanner_profile.project ||= FactoryBot.create(:project)
    end
  end
end
