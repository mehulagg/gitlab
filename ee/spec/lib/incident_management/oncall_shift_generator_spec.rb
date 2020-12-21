# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallShiftGenerator do
  let_it_be(:rotation_start_time) { Time.parse('2020-12-08 00:00:00 UTC').utc }
  let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time) }

  let(:current_time) { Time.parse('2020-12-08 15:00:00 UTC').utc }
  let(:shift_length) { rotation.shift_duration }

  around do |example|
    travel_to(current_time) { example.run }
  end

  shared_context 'with three participants' do
    let_it_be(:participants) do
      {
        user1: create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation),
        user2: create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation),
        user3: create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation)
      }
    end
  end

  # shift_params takes format [[participant identifier, start_time, end_time]]
  # start_time & end_time should include offset/UTC identifier
  # rubocop:disable Rails/TimeZone
  shared_examples 'unsaved rotations' do |shift_params|
    it 'has the expected attributes' do
      expect(shifts).to all( be_a(IncidentManagement::OncallShift) )
      expect(shifts.length).to eq(shift_params.length)

      shifts.each_with_index do |shift, idx|
        expect(shift).to have_attributes(
          id: nil,
          rotation: rotation,
          participant: participants[shift_params[idx][0]],
          starts_at: Time.parse(shift_params[idx][1]),
          ends_at: Time.parse(shift_params[idx][2])
        )
      end
    end
  end
  # rubocop:enable

  shared_examples 'unsaved rotation' do |shift_params|
    let(:shifts) { [shift] }

    include_examples 'unsaved rotations', [shift_params]
  end

  describe '#for_timeframe' do
    let(:starts_at) { Time.parse('2020-12-08 02:00:00 UTC').utc }
    let(:ends_at) { starts_at + (shift_length * 2) }

    subject(:shifts) { described_class.new(rotation).for_timeframe(starts_at: starts_at, ends_at: ends_at) }

    context 'with no participants' do
      it { is_expected.to be_empty }
    end

    context 'with one participant' do
      let_it_be(:participants) { { user: create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) } }

      # Expect 3 shifts of 5 days starting, both for the same user
      it_behaves_like 'unsaved rotations', [
        [:user, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
        [:user, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
        [:user, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']
      ]
    end

    context 'with many participants' do
      include_context 'with three participants'

      context 'when end time is earlier than start time' do
        let(:ends_at) { starts_at - 1.hour }

        it { is_expected.to be_empty }
      end

      context 'when start time is the same time as the rotation start time' do
        let(:starts_at) { rotation_start_time }

        # Expect 2 shifts of 5 days starting with first user
        # at rotation start time
        it_behaves_like 'unsaved rotations', [
          [:user1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
          [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
        ]
      end

      context 'when start time is earlier than the rotation start time' do
        let(:starts_at) { 1.day.before(rotation_start_time) }

        # Expect 2 shifts of 5 days starting with first user
        # at rotation start time
        it_behaves_like 'unsaved rotations', [
          [:user1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
          [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
        ]
      end

      context 'when start time coincides with a shift change' do
        let(:starts_at) { rotation_start_time + shift_length }

        # Expect 2 shift of 5 days, starting with second user
        # starting at 2nd shift
        it_behaves_like 'unsaved rotations', [
          [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
          [:user3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']
        ]
      end

      context 'when start time is partway through a shift' do
        let(:starts_at) { rotation_start_time + (0.6 * shift_length) }

        # Expect 3 shifts of 5 days starting with first user
        # which includes partial shift
        it_behaves_like 'unsaved rotations', [
          [:user1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
          [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
          [:user3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']
        ]
      end

      context 'when the rotation has been completed many times over' do
        let(:starts_at) { rotation_start_time + 7.weeks }

        # Expect 3 shifts of 5 days starting with first user,
        # starting 7 weeks out
        it_behaves_like 'unsaved rotations', [
          [:user1, '2021-01-22 00:00:00 UTC', '2021-01-27 00:00:00 UTC'],
          [:user2, '2021-01-27 00:00:00 UTC', '2021-02-01 00:00:00 UTC'],
          [:user3, '2021-02-01 00:00:00 UTC', '2021-02-06 00:00:00 UTC']
        ]
      end

      context 'when timeframe covers the rotation many times over' do
        let(:ends_at) { starts_at + (shift_length * 6.8) }

        # Expect 7 shifts of 5 days starting with first user
        it_behaves_like 'unsaved rotations', [
          [:user1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
          [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
          [:user3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC'],
          [:user1, '2020-12-23 00:00:00 UTC', '2020-12-28 00:00:00 UTC'],
          [:user2, '2020-12-28 00:00:00 UTC', '2021-01-02 00:00:00 UTC'],
          [:user3, '2021-01-02 00:00:00 UTC', '2021-01-07 00:00:00 UTC'],
          [:user1, '2021-01-07 00:00:00 UTC', '2021-01-12 00:00:00 UTC']
        ]
      end
    end

    context 'in timezones with daylight-savings' do
      let_it_be(:schedule) { create(:incident_management_oncall_schedule, timezone: 'Pacific/Auckland') }

      context 'with rotation in hours' do
        context 'switching to daylight savings time' do
          let_it_be(:rotation_start_time) { Time.parse('2020-09-27').in_time_zone('Pacific/Auckland').beginning_of_day }
          let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :hours, length: 1, schedule: schedule) }

          include_context 'with three participants'

          context 'when overlapping the switch' do
            let(:starts_at) { rotation_start_time }
            let(:ends_at) { (starts_at + 5.hours).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2020-09-27 00:00:00 +1200', '2020-09-27 01:00:00 +1200'],
              [:user2, '2020-09-27 01:00:00 +1200', '2020-09-27 02:00:00 +1200'],
              [:user3, '2020-09-27 03:00:00 +1300', '2020-09-27 04:00:00 +1300'],
              [:user1, '2020-09-27 04:00:00 +1300', '2020-09-27 05:00:00 +1300'],
              [:user2, '2020-09-27 05:00:00 +1300', '2020-09-27 06:00:00 +1300']
            ]
          end

          context 'starting after switch' do
            let(:starts_at) { (rotation_start_time + 4.hours).in_time_zone('Pacific/Auckland') }
            let(:ends_at) { (starts_at + 3.hours).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user2, '2020-09-27 05:00:00 +1300', '2020-09-27 06:00:00 +1300'],
              [:user3, '2020-09-27 06:00:00 +1300', '2020-09-27 07:00:00 +1300'],
              [:user1, '2020-09-27 07:00:00 +1300', '2020-09-27 08:00:00 +1300']
            ]
          end

          context 'starting after multiple switches' do
            let(:starts_at) { Time.parse('2021-04-06').in_time_zone('Pacific/Auckland').beginning_of_day }
            let(:ends_at) { (starts_at + 3.hours).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2021-04-06 00:00:00 +1200', '2021-04-06 01:00:00 +1200'],
              [:user2, '2021-04-06 01:00:00 +1200', '2021-04-06 02:00:00 +1200'],
              [:user3, '2021-04-06 02:00:00 +1200', '2021-04-06 03:00:00 +1200']
            ]
          end
        end

        context 'switching off daylight savings time' do
          let_it_be(:rotation_start_time) { Time.parse('2021-04-04').in_time_zone('Pacific/Auckland').beginning_of_day }
          let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :hours, length: 1, schedule: schedule) }

          include_context 'with three participants'

          context 'when overlapping the switch' do
            let(:starts_at) { rotation_start_time }
            let(:ends_at) { (starts_at + 5.hours).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2021-04-04 00:00:00 +1300', '2021-04-04 01:00:00 +1300'],
              [:user2, '2021-04-04 01:00:00 +1300', '2021-04-04 02:00:00 +1300'],
              [:user3, '2021-04-04 02:00:00 +1300', '2021-04-04 02:00:00 +1200'],
              [:user1, '2021-04-04 02:00:00 +1200', '2021-04-04 03:00:00 +1200'],
              [:user2, '2021-04-04 03:00:00 +1200', '2021-04-04 04:00:00 +1200']
            ]
          end

          context 'starting after switch' do
            let(:starts_at) { (rotation_start_time + 4.hours).in_time_zone('Pacific/Auckland') }
            let(:ends_at) { (starts_at + 3.hours).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user2, '2021-04-04 03:00:00 +1200', '2021-04-04 04:00:00 +1200'],
              [:user3, '2021-04-04 04:00:00 +1200', '2021-04-04 05:00:00 +1200'],
              [:user1, '2021-04-04 05:00:00 +1200', '2021-04-04 06:00:00 +1200']
            ]
          end

          context 'starting after multiple switches' do
            let(:starts_at) { Time.parse('2021-09-27').in_time_zone('Pacific/Auckland').beginning_of_day }
            let(:ends_at) { (starts_at + 3.hours).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2021-09-27 00:00:00 +1300', '2021-09-27 01:00:00 +1300'],
              [:user2, '2021-09-27 01:00:00 +1300', '2021-09-27 02:00:00 +1300'],
              [:user3, '2021-09-27 02:00:00 +1300', '2021-09-27 03:00:00 +1300']
            ]
          end
        end
      end

      context 'with rotation in days' do
        context 'switching to daylight savings time' do
          let_it_be(:rotation_start_time) { Time.parse('2020-09-26').in_time_zone('Pacific/Auckland').beginning_of_day }
          let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :days, length: 1, schedule: schedule) }

          include_context 'with three participants'

          context 'when overlapping the switch' do
            let(:starts_at) { rotation_start_time }
            let(:ends_at) { (starts_at + 4.days).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2020-09-26 00:00:00 +1200', '2020-09-27 00:00:00 +1200'],
              [:user2, '2020-09-27 00:00:00 +1200', '2020-09-28 00:00:00 +1300'],
              [:user3, '2020-09-28 00:00:00 +1300', '2020-09-29 00:00:00 +1300'],
              [:user1, '2020-09-29 00:00:00 +1300', '2020-09-30 00:00:00 +1300']
            ]
          end

          context 'starting after switch' do
            let(:starts_at) { (rotation_start_time + 3.days).in_time_zone('Pacific/Auckland') }
            let(:ends_at) { (starts_at + 3.days).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2020-09-29 00:00:00 +1300', '2020-09-30 00:00:00 +1300'],
              [:user2, '2020-09-30 00:00:00 +1300', '2020-10-01 00:00:00 +1300'],
              [:user3, '2020-10-01 00:00:00 +1300', '2020-10-02 00:00:00 +1300']
            ]
          end

          context 'starting after multiple switches' do
            let(:starts_at) { Time.parse('2021-04-07').in_time_zone('Pacific/Auckland').beginning_of_day }
            let(:ends_at) { (starts_at + 3.days).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user2, '2021-04-07 00:00:00 +1200', '2021-04-08 00:00:00 +1200'],
              [:user3, '2021-04-08 00:00:00 +1200', '2021-04-09 00:00:00 +1200'],
              [:user1, '2021-04-09 00:00:00 +1200', '2021-04-10 00:00:00 +1200']
            ]
          end
        end

        context 'switching off daylight savings time' do
          let_it_be(:rotation_start_time) { Time.parse('2021-04-03').in_time_zone('Pacific/Auckland').beginning_of_day }
          let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :days, length: 1, schedule: schedule) }

          include_context 'with three participants'

          context 'when overlapping the switch' do
            let(:starts_at) { rotation_start_time }
            let(:ends_at) { (starts_at + 4.days).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2021-04-03 00:00:00 +1300', '2021-04-04 00:00:00 +1300'],
              [:user2, '2021-04-04 00:00:00 +1300', '2021-04-05 00:00:00 +1200'],
              [:user3, '2021-04-05 00:00:00 +1200', '2021-04-06 00:00:00 +1200'],
              [:user1, '2021-04-06 00:00:00 +1200', '2021-04-07 00:00:00 +1200']
            ]
          end

          context 'starting after switch' do
            let(:starts_at) { (rotation_start_time + 3.days).in_time_zone('Pacific/Auckland') }
            let(:ends_at) { (starts_at + 3.days).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2021-04-06 00:00:00 +1200', '2021-04-07 00:00:00 +1200'],
              [:user2, '2021-04-07 00:00:00 +1200', '2021-04-08 00:00:00 +1200'],
              [:user3, '2021-04-08 00:00:00 +1200', '2021-04-09 00:00:00 +1200']
            ]
          end

          context 'starting after multiple switches' do
            let(:starts_at) { Time.parse('2021-09-28').in_time_zone('Pacific/Auckland').beginning_of_day }
            let(:ends_at) { (starts_at + 3.days).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user2, '2021-09-28 00:00:00 +1300', '2021-09-29 00:00:00 +1300'],
              [:user3, '2021-09-29 00:00:00 +1300', '2021-09-30 00:00:00 +1300'],
              [:user1, '2021-09-30 00:00:00 +1300', '2021-10-01 00:00:00 +1300']
            ]
          end
        end
      end

      context 'with rotation in weeks' do
        context 'switching to daylight savings time' do
          let_it_be(:rotation_start_time) { Time.parse('2020-09-01').in_time_zone('Pacific/Auckland').at_noon }
          let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :weeks, length: 2, schedule: schedule) }

          include_context 'with three participants'

          context 'when overlapping the switch' do
            let(:starts_at) { rotation_start_time }
            let(:ends_at) { (starts_at + 6.weeks).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2020-09-01 12:00:00 +1200', '2020-09-15 12:00:00 +1200'],
              [:user2, '2020-09-15 12:00:00 +1200', '2020-09-29 12:00:00 +1300'],
              [:user3, '2020-09-29 12:00:00 +1300', '2020-10-13 12:00:00 +1300']
            ]
          end

          context 'starting after switch' do
            let(:starts_at) { (rotation_start_time + 4.weeks).in_time_zone('Pacific/Auckland') }
            let(:ends_at) { (starts_at + 4.weeks).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user3, '2020-09-29 12:00:00 +1300', '2020-10-13 12:00:00 +1300'],
              [:user1, '2020-10-13 12:00:00 +1300', '2020-10-27 12:00:00 +1300']
            ]
          end

          context 'starting after multiple switches' do
            let(:starts_at) { Time.parse('2021-04-18').in_time_zone('Pacific/Auckland').at_noon }
            let(:ends_at) { (starts_at + 5.weeks).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user2, '2021-04-13 12:00:00 +1200', '2021-04-27 12:00:00 +1200'],
              [:user3, '2021-04-27 12:00:00 +1200', '2021-05-11 12:00:00 +1200'],
              [:user1, '2021-05-11 12:00:00 +1200', '2021-05-25 12:00:00 +1200']
            ]
          end
        end

        context 'switching off daylight savings time' do
          let_it_be(:rotation_start_time) { Time.parse('2021-03-21').in_time_zone('Pacific/Auckland').at_noon }
          let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :weeks, length: 2, schedule: schedule) }

          include_context 'with three participants'

          context 'when overlapping the switch' do
            let(:starts_at) { rotation_start_time }
            let(:ends_at) { (starts_at + 6.weeks).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user1, '2021-03-21 12:00:00 +1300', '2021-04-04 12:00:00 +1200'],
              [:user2, '2021-04-04 12:00:00 +1200', '2021-04-18 12:00:00 +1200'],
              [:user3, '2021-04-18 12:00:00 +1200', '2021-05-02 12:00:00 +1200']
            ]
          end

          context 'starting after switch' do
            let(:starts_at) { (rotation_start_time + 4.weeks).in_time_zone('Pacific/Auckland') }
            let(:ends_at) { (starts_at + 4.weeks).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user3, '2021-04-18 12:00:00 +1200', '2021-05-02 12:00:00 +1200'],
              [:user1, '2021-05-02 12:00:00 +1200', '2021-05-16 12:00:00 +1200']
            ]
          end

          context 'starting after multiple switches' do
            let(:starts_at) { Time.parse('2021-09-30').in_time_zone('Pacific/Auckland').at_noon }
            let(:ends_at) { (starts_at + 5.weeks).in_time_zone('Pacific/Auckland') }

            it_behaves_like 'unsaved rotations', [
              [:user2, '2021-09-19 12:00:00 +1200', '2021-10-03 12:00:00 +1300'],
              [:user3, '2021-10-03 12:00:00 +1300', '2021-10-17 12:00:00 +1300'],
              [:user1, '2021-10-17 12:00:00 +1300', '2021-10-31 12:00:00 +1300'],
              [:user2, '2021-10-31 12:00:00 +1300', '2021-11-14 12:00:00 +1300']
            ]
          end
        end
      end
    end
  end

  describe '#for_timestamp' do
    let(:timestamp) { Time.current }

    subject(:shift) { described_class.new(rotation).for_timestamp(timestamp) }

    context 'with no participants' do
      it { is_expected.to be_nil }
    end

    context 'with participants' do
      include_context 'with three participants'

      context 'when timestamp is before the rotation start time' do
        let(:timestamp) { rotation_start_time - 10.minutes }

        it { is_expected.to be_nil }
      end

      context 'when timestamp matches the rotation start time' do
        let(:timestamp) { rotation_start_time }

        it_behaves_like 'unsaved rotation', [:user1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC']
      end

      context 'when timestamp matches a shift start/end time' do
        let(:timestamp) { rotation_start_time + shift_length }

        it_behaves_like 'unsaved rotation', [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
      end

      context 'when timestamp is in the middle of a shift' do
        let(:timestamp) { rotation_start_time + (1.6 * shift_length) }

        it_behaves_like 'unsaved rotation', [:user2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
      end
    end
  end
end
