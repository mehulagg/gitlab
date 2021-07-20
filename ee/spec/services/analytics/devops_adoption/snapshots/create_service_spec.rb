# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::CreateService do
  subject(:service_response) { described_class.new(params: params).execute }

  let(:snapshot) { service_response.payload[:snapshot] }
  let(:params) do
    params = {}
    Analytics::DevopsAdoption::Snapshot::BOOLEAN_METRICS.each.with_index do |attribute, i|
      params[attribute] = i.odd?
    end
    Analytics::DevopsAdoption::Snapshot::NUMERIC_METRICS.each.with_index do |attribute, i|
      params[attribute] = i
    end

    params[:recorded_at] = Time.zone.now
    params[:end_time] = 1.month.ago.end_of_month
    params[:namespace] = enabled_namespace.namespace
    params
  end

  let(:enabled_namespace) { create(:devops_adoption_enabled_namespace) }

  it 'persists the snapshot' do
    expect(subject).to be_success
    expect(snapshot).to have_attributes(params)
  end

  context 'when params are invalid' do
    let(:params) { super().merge(recorded_at: nil) }

    it 'does not persist the snapshot' do
      expect(subject).to be_error
      expect(subject.message).to eq('Validation error')
      expect(snapshot).not_to be_persisted
    end
  end
end
