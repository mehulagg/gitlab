# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallShiftGenerator do
  let_it_be(:rotation_start_time) { Time.zone.parse('2020-12-08 00:00:00 UTC') }
  let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time) }

  let(:current_time) { Time.parse('2020-12-08 15:00:00 UTC') }
  let(:starts_at) { Time.zone.parse('2020-12-08 02:00:00 UTC') }
  let(:ends_at) { starts_at + (shift_length * 2) }
  let(:shift_length) { rotation.shift_duration }

  subject(:shifts) { described_class.new(rotation, starts_at: starts_at, ends_at: ends_at).execute }

  around do |example|
    travel_to(current_time) { example.run }
  end

  # shift_params takes format [[participant identifier, start_time, end_time]]
  shared_examples 'unsaved rotations' do |shift_params|
    it 'has the expected attributes' do
      expect(shifts).to all( be_a(IncidentManagement::OncallShift) )

      shifts.each_with_index do |shift, idx|
        expect(shift).to have_attributes(
          id: nil,
          rotation: rotation,
          participant: participants[shift_params[idx][0]],
          starts_at: Time.parse(shift_params[idx][1] + 'UTC'),
          ends_at: Time.parse(shift_params[idx][2] + 'UTC')
        )
      end
      expect(shifts.length).to eq(shift_params.length)
    end
  end

  context 'with no participants' do
    it { is_expected.to be_empty }
  end

  context 'with one participant' do
    let_it_be(:participants) { { user: create(:incident_management_oncall_participant, :with_access, rotation: rotation) } }

    # Expect 3 shifts of 5 days starting, both for the same user
    it_behaves_like 'unsaved rotations', [
      [:user, '2020-12-08 00:00:00', '2020-12-13 00:00:00'],
      [:user, '2020-12-13 00:00:00', '2020-12-18 00:00:00'],
      [:user, '2020-12-18 00:00:00', '2020-12-23 00:00:00']
    ]
  end

  context 'with many participants' do
    let_it_be(:participants) do
      {
        blue200: create(:incident_management_oncall_participant, :with_access, rotation: rotation, color_palette: :blue, color_weight: '200'),
        blue50: create(:incident_management_oncall_participant, :with_access, rotation: rotation, color_palette: :blue, color_weight: '50'),
        magenta: create(:incident_management_oncall_participant, :with_access, rotation: rotation, color_palette: :magenta),
      }
    end

    context 'when end time is earlier than start time' do
      let(:ends_at) { starts_at - 1.hour }

      it { is_expected.to be_empty }
    end

    context 'when start time is the same time as the rotation start time' do
      let(:starts_at) { rotation_start_time }

      # Expect 2 shifts of 5 days starting with first user
      # at rotation start time
      it_behaves_like 'unsaved rotations', [
        [:blue50, '2020-12-08 00:00:00', '2020-12-13 00:00:00'],
        [:blue200, '2020-12-13 00:00:00', '2020-12-18 00:00:00']
      ]
    end

    context 'when start time is earlier than the rotation start time' do
      let(:starts_at) { 1.day.before(rotation_start_time) }

      # Expect 2 shifts of 5 days starting with first user
      # at rotation start time
      it_behaves_like 'unsaved rotations', [
        [:blue50, '2020-12-08 00:00:00', '2020-12-13 00:00:00'],
        [:blue200, '2020-12-13 00:00:00', '2020-12-18 00:00:00'],
      ]
    end

    context 'when start time coincides with a shift change' do
      let(:starts_at) { rotation_start_time + shift_length }

      # Expect 2 shift of 5 days, starting with second user
      # starting at 2nd shift
      it_behaves_like 'unsaved rotations', [
        [:blue200, '2020-12-13 00:00:00', '2020-12-18 00:00:00'],
        [:magenta, '2020-12-18 00:00:00', '2020-12-23 00:00:00'],
      ]
    end

    context 'when start time is partway through a shift' do
      let(:starts_at) { rotation_start_time + (0.6 * shift_length) }

      # Expect 3 shifts of 5 days starting with first user
      # which includes partial shift
      it_behaves_like 'unsaved rotations', [
        [:blue50, '2020-12-08 00:00:00', '2020-12-13 00:00:00'],
        [:blue200, '2020-12-13 00:00:00', '2020-12-18 00:00:00'],
        [:magenta, '2020-12-18 00:00:00', '2020-12-23 00:00:00']
      ]
    end

    context 'when the rotation has been completed many times over' do
      let(:starts_at) { rotation_start_time + 7.weeks }

      # Expect 3 shifts of 5 days starting with first user,
      # starting 7 weeks out
      it_behaves_like 'unsaved rotations', [
        [:blue50,'2021-01-22 00:00:00', '2021-01-27 00:00:00'],
        [:blue200,'2021-01-27 00:00:00', '2021-02-01 00:00:00'],
        [:magenta,'2021-02-01 00:00:00', '2021-02-06 00:00:00']
      ]
    end

    context 'when timeframe covers the rotation many times over' do
      let(:ends_at) { starts_at + (shift_length * 6.8) }

      # Expect 7 shifts of 5 days starting with first user
      it_behaves_like 'unsaved rotations', [
        [:blue50, '2020-12-08 00:00:00', '2020-12-13 00:00:00'],
        [:blue200, '2020-12-13 00:00:00', '2020-12-18 00:00:00'],
        [:magenta, '2020-12-18 00:00:00', '2020-12-23 00:00:00'],
        [:blue50, '2020-12-23 00:00:00', '2020-12-28 00:00:00'],
        [:blue200, '2020-12-28 00:00:00', '2021-01-02 00:00:00'],
        [:magenta, '2021-01-02 00:00:00', '2021-01-07 00:00:00'],
        [:blue50, '2021-01-07 00:00:00', '2021-01-12 00:00:00']
      ]
    end
  end
end
