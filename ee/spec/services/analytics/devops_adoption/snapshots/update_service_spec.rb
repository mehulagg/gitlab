# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::UpdateService do
  subject(:service_response) { described_class.new(snapshot: snapshot, params: params).execute }

  let(:snapshot) { create(:devops_adoption_snapshot) }

  let(:params) do
    params = {}
    Analytics::DevopsAdoption::Snapshot::BOOLEAN_METRICS.each.with_index do |attribute, i|
      params[attribute] = i.odd?
    end
    Analytics::DevopsAdoption::Snapshot::NUMERIC_METRICS.each.with_index do |attribute, i|
      params[attribute] = i
    end
    params[:recorded_at] = Time.zone.now
    params[:namespace] = snapshot.namespace
    params
  end

  it 'updates the snapshot' do
    expect(subject).to be_success
    expect(snapshot).to have_attributes(params)
  end

  context 'when params are invalid' do
    let(:params) { super().merge(recorded_at: nil) }

    it 'does not update the snapshot' do
      expect(subject).to be_error
      expect(subject.message).to eq('Validation error')
      expect(snapshot.reload.recorded_at).not_to be_nil
    end
  end
end
