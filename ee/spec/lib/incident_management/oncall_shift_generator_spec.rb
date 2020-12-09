# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallShiftGenerator do
  let!(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time) }
  let!(:participants) { create_list(:incident_management_oncall_participant, 3, :with_access, rotation: rotation) }

  let(:rotation_start_time) { Time.zone.parse('2020-12-08 00:00:00') }
  let(:current_time) { Time.zone.parse('2020-12-08 19:58:45.385074') }
  let(:starts_at) { 2.weeks.ago }
  let(:ends_at) { 3.days.from_now }

  subject(:shifts) { described_class.new(rotation, starts_at: starts_at, ends_at: ends_at).execute }

  around do |example|
    Timecop.freeze(current_time) { example.run }
  end

  shared_examples 'unsaved rotations' do |rotation_params|
    it 'has the expected attributes' do
      expect(shifts).to all( be_a(IncidentManagement::OncallShift) )
      expect(shifts).to all( have_attributes(id: nil) )
    end
  end

  context 'when start time is earlier than the rotation start time' do
    let(:starts_at) { 1.day.before(rotation.starts_at) }

    it { is_expected.to be_empty }
    #<IncidentManagement::OncallShift id: nil, rotation_id: 1, participant_id: 1, starts_at: "2020-12-08 00:00:00", ends_at: "2020-12-13 00:00:00">
  end

  context 'when end time is earlier than start time' do
    let(:ends_at) { starts_at - 1.hour }

    it { is_expected.to be_empty }
  end

  context 'when start time is the same time as the rotation start time' do
    let(:rotation_start_time) { starts_at }

    it { is_expected.to be_empty }
  end

  context 'when start time coincides with a shift change' do
    # Use 2X shift length for rotation factory
    let(:rotation_start_time) { starts_at + 10.days }

    it { is_expected.to be_empty }
  end

  context 'when start time partway through a shift' do
    # Use a random duration which is not a multiple of shift length in rotation factory
    let(:rotation_start_time) { starts_at + 2.7.days }

    it { is_expected.to be_empty }
  end

  context 'when the rotation has been completed many times over' do
    let(:rotation_start_time) { starts_at + 7.weeks }

    it { is_expected.to be_empty }
  end

  context 'when timeframe covers the rotation many times over' do
    let(:ends_at) { }
  end

  context 'with no participants' do
    let!(:participants) { [] }

    it { is_expected.to be_empty }
  end

  context 'with one participant' do
    let!(:participants) { create(:incident_management_oncall_participant, :with_access, rotation: rotation) }

    it { is_expected.to be_empty }
  end
end
