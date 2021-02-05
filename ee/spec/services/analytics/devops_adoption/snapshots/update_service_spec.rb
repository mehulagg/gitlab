# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::Snapshots::UpdateService do
  subject(:service_response) { described_class.new(snapshot: snapshot, params: params).execute }

  let(:snapshot) { create(:devops_adoption_snapshot, segment: segment) }
  let(:segment) { create(:devops_adoption_segment, last_recorded_at: 1.year.ago) }

  let(:params) do
    params = Analytics::DevopsAdoption::SnapshotCalculator::ADOPTION_FLAGS.each_with_object({}) do |attribute, result|
      result[attribute] = rand(2).odd?
    end
    params[:recorded_at] = Time.zone.now
    params[:segment] = segment
    params
  end

  it 'updates the snapshot & updates segment last recorded at date' do
    expect(subject).to be_success
    expect(snapshot).to have_attributes(params)
    expect(snapshot.segment.reload.last_recorded_at).to be_like_time(snapshot.recorded_at)
  end

  context 'when params are invalid' do
    let(:params) { super().merge(recorded_at: nil) }

    it 'does not update the snapshot' do
      expect(subject).to be_error
      expect(subject.message).to eq('Validation error')
      expect(snapshot.reload.recorded_at).not_to be_nil
      expect(snapshot.segment.reload.last_recorded_at).not_to eq nil
    end
  end
end
