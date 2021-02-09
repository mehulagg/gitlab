# frozen_string_literal: true

FactoryBot.define do
  factory :geo_secondary_usage_data, class: 'Geo::SecondaryUsageData' do
    Geo::SecondaryUsageData::RESOURCE_DATA_FIELDS.each do |field|
      case field
      when /_count\z/ then send(field) { rand(10000) }
      when /_enabled\z/ then send(field) { [true, false].sample }
      else raise "Unhandled status attribute name format \"#{field}\""
      end
    end
  end
end
