# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::SecondaryUsageData, :geo, type: :model do
  subject { create(:geo_secondary_usage_data) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'cannot have undefined fields in the payload' do
    subject.payload['nope_does_not_exist'] = 'whatever'
    expect(subject).not_to be_valid
  end

  shared_examples_for 'a payload count field' do |field|
    it "defines #{field} as a method" do
      expect(subject.methods).to include(field.to_sym)
    end

    it "does not allow #{field} to be a string" do
      subject.payload[field] = 'a string'
      expect(subject).not_to be_valid
    end

    it "allows #{field} to be nil" do
      subject.payload[field] = nil
      expect(subject).to be_valid
    end

    it "may not define #{field} in the payload json" do
      subject.payload.except!(field)
      expect(subject).to be_valid
    end
  end

  Geo::SecondaryUsageData::PAYLOAD_COUNT_FIELDS.each do |field|
    context "##{field}" do
      it_behaves_like 'a payload count field', field
    end
  end
end
