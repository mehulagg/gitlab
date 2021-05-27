# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService do
  let_it_be(:segment) { create :devops_adoption_segment }

  subject { described_class.new(segment: segment, range_end: range_end) }

  let(:range_end) { Time.zone.now.end_of_month }
  let(:snapshot) { nil }

  before do
    allow_next_instance_of(Analytics::DevopsAdoption::SnapshotCalculator, segment: segment, range_end: range_end, snapshot: snapshot) do |calc|
      allow(calc).to receive(:calculate).and_return('calculated_data')
    end
  end

  it 'creates a snapshot with whatever snapshot calculator returns' do
    expect_next_instance_of(Analytics::DevopsAdoption::Snapshots::CreateService, params: 'calculated_data') do |service|
      expect(service).to receive(:execute).and_return('create_service_response')
    end

    expect(subject.execute).to eq('create_service_response')
  end

  context 'when a snapshot for given range already exists' do
    let(:snapshot) { create :devops_adoption_snapshot, end_time: range_end, namespace: segment.namespace }

    it 'updates the snapshot with whatever snapshot calculator returns' do
      expect_next_instance_of(Analytics::DevopsAdoption::Snapshots::UpdateService, snapshot: snapshot, params: 'calculated_data') do |service|
        expect(service).to receive(:execute).and_return('update_service_response')
      end

      expect(subject.execute).to eq('update_service_response')
    end
  end
end
