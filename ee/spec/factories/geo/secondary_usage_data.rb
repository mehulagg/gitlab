# frozen_string_literal: true

FactoryBot.define do
  factory :geo_secondary_usage_data, class: 'Geo::SecondaryUsageData' do
    Geo::SecondaryUsageData::PAYLOAD_COUNT_FIELDS.each do |field|
      send(field) { rand(10000) }
    end
  end
end
