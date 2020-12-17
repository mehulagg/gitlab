# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService do
  let(:segment_mock) { instance_double('Analytics::DevopsAdoption::Segment') }

  subject { described_class.new(segment: segment_mock) }

  it 'creates a snapshot with whatever snapshot calculator returns' do
    allow_next_instance_of(Analytics::DevopsAdoption::SnapshotCalculator) do |calc|
      allow(calc).to receive(:calculate).and_return('calculated_data')
    end

    expect_next_instance_of(Analytics::DevopsAdoption::Snapshots::CreateService, params: 'calculated_data') do |service|
      expect(service).to receive(:execute).and_return('create_service_response')
    end

    expect(subject.execute).to eq('create_service_response')
  end
end
