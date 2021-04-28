# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::CreateService do
  subject(:service_response) { described_class.new(params: params).execute }

  let(:snapshot) { service_response.payload[:snapshot] }
  let(:params) do
    params = {}
    Analytics::DevopsAdoption::SnapshotCalculator::BOOLEAN_METRICS.each.with_index do |attribute, i|
      params[attribute] = i.odd?
    end
    Analytics::DevopsAdoption::SnapshotCalculator::NUMERIC_METRICS.each.with_index do |attribute, i|
      params[attribute] = i
    end

    params[:recorded_at] = Time.zone.now
    params[:end_time] = 1.month.ago.end_of_month
    params[:segment] = segment
    params
  end

  let(:segment) { create(:devops_adoption_segment, last_recorded_at: 1.year.ago) }

  it 'persists the snapshot & updates segment last recorded at date' do
    expect(subject).to be_success
    expect(snapshot).to have_attributes(params)
    expect(snapshot.segment.reload.last_recorded_at).to be_like_time(snapshot.recorded_at)
  end

  context 'when params are invalid' do
    let(:params) { super().merge(recorded_at: nil) }

    it 'does not persist the snapshot' do
      expect(subject).to be_error
      expect(subject.message).to eq('Validation error')
      expect(snapshot).not_to be_persisted
      expect(snapshot.segment.reload.last_recorded_at).not_to eq nil
    end
  end
end
