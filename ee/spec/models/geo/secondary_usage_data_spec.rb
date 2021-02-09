# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SecondaryUsageData, :geo, type: :model do
  subject { create(:geo_secondary_usage_data) }

  it 'defines methods for resource data fields' do
    Geo::SecondaryUsageData::RESOURCE_DATA_FIELDS.each do |field|
      expect(subject.methods).to include(field)
    end
  end
end
