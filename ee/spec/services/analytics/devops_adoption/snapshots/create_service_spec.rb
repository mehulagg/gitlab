# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::CreateService do
  subject(:service_response) { described_class.new(params: params).execute }

  let(:snapshot) { service_response.payload[:snapshot] }
  let(:params) do
    params = Analytics::DevopsAdoption::SnapshotCalculator::ADOPTION_FLAGS.each_with_object({}) do |attribute, result|
      result[attribute] = rand(2).odd?
    end
    params[:recorded_at] = Time.zone.now
    params[:segment] = segment
    params
  end

  let_it_be(:segment) { create(:devops_adoption_segment) }

  it 'persists the segment' do
    expect(subject).to be_success
    expect(snapshot).to have_attributes(params)
  end

  context 'when params are invalid' do
    let(:params) { super().merge(recorded_at: nil) }

    it 'does not persist the segment' do
      expect(subject).to be_error
      expect(subject.message).to eq('Validation error')
      expect(snapshot).not_to be_persisted
    end
  end
end
