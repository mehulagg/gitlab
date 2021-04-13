# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallShiftGenerator do
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, timezone: 'Etc/UTC') }
  let_it_be(:rotation_start_time) { Time.parse('2020-12-08 00:00:00 UTC').utc }
  let_it_be_with_reload(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length: 5, length_unit: :days, schedule: schedule) }

  let(:current_time) { Time.parse('2020-12-08 15:00:00 UTC').utc }
  let(:shift_length) { rotation.shift_cycle_duration }

  around do |example|
    travel_to(current_time) { example.run }
  end

  shared_context 'with three participants' do
    let_it_be(:participant1) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
    let_it_be(:participant2) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
    let_it_be(:participant3) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
  end

  # Compares generated shifts to expected output.
  # params:
  #   description -> String
  #   shift_params -> formatted as [[participant identifier(Symbol), start_time(String), end_time(String)]].
  #                   start_time & end_time should include offset/UTC identifier.
  #                   participant identifier should reference the variable name of a participant.
  #
  # Example) [[:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']]
  #          :participant2 would reference `let(:participant2)`
  shared_examples 'unsaved shifts' do |description, shift_params|
    it "returns #{description}", :aggregate_failures do
      expect(shifts).to all(be_a(IncidentManagement::OncallShift))
      expect(shifts.length).to eq(shift_params.length)

      shifts.each_with_index do |shift, idx|
        expect(shift).to have_attributes(
          id: nil,
          rotation: rotation,
          participant: send(shift_params[idx][0]),
          starts_at: Time.zone.parse(shift_params[idx][1]),
          ends_at: Time.zone.parse(shift_params[idx][2])
        )
      end
    end
  end

  # For asserting the response is a singular shift rather
  # than an array of shifts
  shared_examples 'unsaved shift' do |description, shift_params|
    let(:shifts) { [shift] }

    include_examples 'unsaved shifts', description, [shift_params]
  end

  describe '#for_timeframe' do
    let(:starts_at) { Time.parse('2020-12-08 02:00:00 UTC').utc }
    let(:ends_at) { starts_at + (shift_length * 2) }

    subject(:shifts) { described_class.new(rotation).for_timeframe(starts_at: starts_at, ends_at: ends_at) }

    context 'with no participants' do
      it { is_expected.to be_empty }
    end

    context 'with one participant' do
      let_it_be(:participant) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }

      it_behaves_like 'unsaved shifts',
       '3 shifts of 5 days, all for the same participant',
       [[:participant, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
        [:participant, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
        [:participant, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']]

      context 'when timestamp is at the end of a shift' do
        let(:starts_at) { rotation_start_time + shift_length }

        it_behaves_like 'unsaved shifts',
          'the second and third shift',
          [[:participant, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
           [:participant, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']]
      end
    end

    context 'with many participants' do
      include_context 'with three participants'

      it_behaves_like 'unsaved shifts',
        'One shift of 5 days long for each participant',
        [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
         [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
         [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']]

      context 'with shift active period times set' do
        let(:active_period_start) { "08:00" }
        let(:active_period_end) { "17:00" }

        before do
          rotation.update!(
            active_period_start: active_period_start,
            active_period_end: active_period_end
          )
        end

        it 'splits the shifts daily by each active period' do
          expect(shifts.count).to eq (ends_at.to_date - starts_at.to_date).to_i
        end

        it_behaves_like 'unsaved shifts',
          '5 shifts for each participant split by each day',
          [[:participant1, '2020-12-08 08:00:00 UTC', '2020-12-08 17:00:00 UTC'],
           [:participant1, '2020-12-09 08:00:00 UTC', '2020-12-09 17:00:00 UTC'],
           [:participant1, '2020-12-10 08:00:00 UTC', '2020-12-10 17:00:00 UTC'],
           [:participant1, '2020-12-11 08:00:00 UTC', '2020-12-11 17:00:00 UTC'],
           [:participant1, '2020-12-12 08:00:00 UTC', '2020-12-12 17:00:00 UTC'],
           [:participant2, '2020-12-13 08:00:00 UTC', '2020-12-13 17:00:00 UTC'],
           [:participant2, '2020-12-14 08:00:00 UTC', '2020-12-14 17:00:00 UTC'],
           [:participant2, '2020-12-15 08:00:00 UTC', '2020-12-15 17:00:00 UTC'],
           [:participant2, '2020-12-16 08:00:00 UTC', '2020-12-16 17:00:00 UTC'],
           [:participant2, '2020-12-17 08:00:00 UTC', '2020-12-17 17:00:00 UTC']]

        context 'with week length unit' do
          before do
            rotation.update!(
              length_unit: :weeks,
              length: 1
            )
          end

          it 'splits the shifts daily by each active period' do
            expect(shifts.count).to eq (ends_at.to_date - starts_at.to_date).to_i
          end

          it_behaves_like 'unsaved shifts',
            '7 shifts for each participant split by each day',
            [[:participant1, '2020-12-08 08:00:00 UTC', '2020-12-08 17:00:00 UTC'],
             [:participant1, '2020-12-09 08:00:00 UTC', '2020-12-09 17:00:00 UTC'],
             [:participant1, '2020-12-10 08:00:00 UTC', '2020-12-10 17:00:00 UTC'],
             [:participant1, '2020-12-11 08:00:00 UTC', '2020-12-11 17:00:00 UTC'],
             [:participant1, '2020-12-12 08:00:00 UTC', '2020-12-12 17:00:00 UTC'],
             [:participant1, '2020-12-13 08:00:00 UTC', '2020-12-13 17:00:00 UTC'],
             [:participant1, '2020-12-14 08:00:00 UTC', '2020-12-14 17:00:00 UTC'],
             [:participant2, '2020-12-15 08:00:00 UTC', '2020-12-15 17:00:00 UTC'],
             [:participant2, '2020-12-16 08:00:00 UTC', '2020-12-16 17:00:00 UTC'],
             [:participant2, '2020-12-17 08:00:00 UTC', '2020-12-17 17:00:00 UTC'],
             [:participant2, '2020-12-18 08:00:00 UTC', '2020-12-18 17:00:00 UTC'],
             [:participant2, '2020-12-19 08:00:00 UTC', '2020-12-19 17:00:00 UTC'],
             [:participant2, '2020-12-20 08:00:00 UTC', '2020-12-20 17:00:00 UTC'],
             [:participant2, '2020-12-21 08:00:00 UTC', '2020-12-21 17:00:00 UTC']]
        end

        context 'rotation start time is in middle of active period' do
          before do
            rotation.update!(starts_at: rotation_start_time.change(hour: 10))
          end

          it_behaves_like 'unsaved shifts',
            '5 shifts for each participant split by each day',
            [[:participant1, '2020-12-08 10:00:00 UTC', '2020-12-08 17:00:00 UTC'],
             [:participant1, '2020-12-09 08:00:00 UTC', '2020-12-09 17:00:00 UTC'],
             [:participant1, '2020-12-10 08:00:00 UTC', '2020-12-10 17:00:00 UTC'],
             [:participant1, '2020-12-11 08:00:00 UTC', '2020-12-11 17:00:00 UTC'],
             [:participant1, '2020-12-12 08:00:00 UTC', '2020-12-12 17:00:00 UTC'],
             [:participant2, '2020-12-13 08:00:00 UTC', '2020-12-13 17:00:00 UTC'],
             [:participant2, '2020-12-14 08:00:00 UTC', '2020-12-14 17:00:00 UTC'],
             [:participant2, '2020-12-15 08:00:00 UTC', '2020-12-15 17:00:00 UTC'],
             [:participant2, '2020-12-16 08:00:00 UTC', '2020-12-16 17:00:00 UTC'],
             [:participant2, '2020-12-17 08:00:00 UTC', '2020-12-17 17:00:00 UTC']]
        end

        context 'active period is overnight' do
          let(:active_period_start) { "17:00" }
          let(:active_period_end) { "08:00" }

          it 'splits the shifts daily by each active period' do
            expect(shifts.count).to eq (ends_at.to_date - starts_at.to_date).to_i
          end

          it_behaves_like 'unsaved shifts',
          '5 shifts for each participant with overnight shifts',
          [[:participant1, '2020-12-08 17:00:00 UTC', '2020-12-09 08:00:00 UTC'],
           [:participant1, '2020-12-09 17:00:00 UTC', '2020-12-10 08:00:00 UTC'],
           [:participant1, '2020-12-10 17:00:00 UTC', '2020-12-11 08:00:00 UTC'],
           [:participant1, '2020-12-11 17:00:00 UTC', '2020-12-12 08:00:00 UTC'],
           [:participant1, '2020-12-12 17:00:00 UTC', '2020-12-13 08:00:00 UTC'],
           [:participant2, '2020-12-13 17:00:00 UTC', '2020-12-14 08:00:00 UTC'],
           [:participant2, '2020-12-14 17:00:00 UTC', '2020-12-15 08:00:00 UTC'],
           [:participant2, '2020-12-15 17:00:00 UTC', '2020-12-16 08:00:00 UTC'],
           [:participant2, '2020-12-16 17:00:00 UTC', '2020-12-17 08:00:00 UTC'],
           [:participant2, '2020-12-17 17:00:00 UTC', '2020-12-18 08:00:00 UTC']]
        end
      end

      context 'when end time is earlier than start time' do
        let(:ends_at) { starts_at - 1.hour }

        it { is_expected.to be_empty }
      end

      context 'when start time is the same time as the rotation start time' do
        let(:starts_at) { rotation_start_time }

        it_behaves_like 'unsaved shifts',
          '2 shifts of 5 days starting with first participant at the rotation start time',
          [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
           [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']]
      end

      context 'when start time is earlier than the rotation start time' do
        let(:starts_at) { 1.day.before(rotation_start_time) }

        it_behaves_like 'unsaved shifts',
          '2 shifts of 5 days starting with the first participant at the rotation start time',
          [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
           [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']]
      end

      context 'when start time coincides with a shift change' do
        let(:starts_at) { rotation_start_time + shift_length }

        it_behaves_like 'unsaved shifts',
          '2 shifts of 5 days, starting with the second participant and the second shift',
          [[:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
           [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']]
      end

      context 'when start time is partway through a shift' do
        let(:starts_at) { rotation_start_time + (0.6 * shift_length) }

        it_behaves_like 'unsaved shifts',
          '3 shifts of 5 days staring with the first participant which includes the partially completed shift',
          [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
           [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
           [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']]
      end

      context 'when the rotation has been completed many times over' do
        let(:starts_at) { rotation_start_time + 7.weeks }

        it_behaves_like 'unsaved shifts',
          '3 shifts of 5 days starting with the first participant beginning 7 weeks after rotation start time',
          [[:participant1, '2021-01-22 00:00:00 UTC', '2021-01-27 00:00:00 UTC'],
           [:participant2, '2021-01-27 00:00:00 UTC', '2021-02-01 00:00:00 UTC'],
           [:participant3, '2021-02-01 00:00:00 UTC', '2021-02-06 00:00:00 UTC']]
      end

      context 'when timeframe covers the rotation many times over' do
        let(:ends_at) { starts_at + (shift_length * 6.8) }

        it_behaves_like 'unsaved shifts',
          '7 shifts of 5 days starting with the first participant',
          [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
           [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
           [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC'],
           [:participant1, '2020-12-23 00:00:00 UTC', '2020-12-28 00:00:00 UTC'],
           [:participant2, '2020-12-28 00:00:00 UTC', '2021-01-02 00:00:00 UTC'],
           [:participant3, '2021-01-02 00:00:00 UTC', '2021-01-07 00:00:00 UTC'],
           [:participant1, '2021-01-07 00:00:00 UTC', '2021-01-12 00:00:00 UTC']]
      end

      context 'with rotation end time' do
        let(:equal_to) { rotation_end_time }
        let(:less_than) { 10.minutes.before(rotation_end_time) }
        let(:greater_than) { 10.minutes.after(rotation_end_time) }
        let(:well_past) { shift_length.after(rotation_end_time) }

        before do
          rotation.update!(ends_at: rotation_end_time)
        end

        context 'when the rotation end time coincides with a shift end' do
          let(:rotation_end_time) { rotation_start_time + (shift_length * 3) }

          [:equal_to, :less_than, :greater_than, :well_past].each do |scenario|
            context "when end time is #{scenario} the rotation end time" do
              let(:ends_at) { send(scenario) }

              it_behaves_like 'unsaved shifts',
                '3 shifts of 5 days which ends at the rotation end time',
                [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
                 [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
                 [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-23 00:00:00 UTC']]
            end
          end
        end

        context 'when the rotation end time is partway through a shift' do
          let(:rotation_end_time) { rotation_start_time + (shift_length * 2.5) }

          [:equal_to, :less_than, :greater_than, :well_past].each do |scenario|
            context "when end time is #{scenario} the rotation end time" do
              let(:ends_at) { send(scenario) }

              it_behaves_like 'unsaved shifts',
                '2 shifts of 5 days and one partial shift which ends at the rotation end time',
                [[:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC'],
                 [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC'],
                 [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-20 12:00:00 UTC']]
            end
          end
        end
      end
    end

    context 'in timezones with daylight-savings' do
      context 'with positive UTC offsets' do
        let_it_be(:schedule) { create(:incident_management_oncall_schedule, timezone: 'Pacific/Auckland') }

        context 'with rotation in hours' do
          context 'switching to daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('Pacific/Auckland').parse('2020-09-27').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :hours, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 5.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which start in NZST(+1200) and switch to NZDT(+1300)',
                [[:participant1, '2020-09-27 00:00:00 +1200', '2020-09-27 01:00:00 +1200'],
                 [:participant2, '2020-09-27 01:00:00 +1200', '2020-09-27 02:00:00 +1200'],
                 [:participant3, '2020-09-27 03:00:00 +1300', '2020-09-27 04:00:00 +1300'],
                 [:participant1, '2020-09-27 04:00:00 +1300', '2020-09-27 05:00:00 +1300'],
                 [:participant2, '2020-09-27 05:00:00 +1300', '2020-09-27 06:00:00 +1300']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.hours }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely in NZDT(+1300)',
                [[:participant2, '2020-09-27 05:00:00 +1300', '2020-09-27 06:00:00 +1300'],
                 [:participant3, '2020-09-27 06:00:00 +1300', '2020-09-27 07:00:00 +1300'],
                 [:participant1, '2020-09-27 07:00:00 +1300', '2020-09-27 08:00:00 +1300']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('Pacific/Auckland').parse('2021-04-06').beginning_of_day }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely back in NZST(+1200) after 2 timezone switches since the rotation start time',
                [[:participant1, '2021-04-06 00:00:00 +1200', '2021-04-06 01:00:00 +1200'],
                 [:participant2, '2021-04-06 01:00:00 +1200', '2021-04-06 02:00:00 +1200'],
                 [:participant3, '2021-04-06 02:00:00 +1200', '2021-04-06 03:00:00 +1200']]
            end
          end

          context 'switching off daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('Pacific/Auckland').parse('2021-04-04').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :hours, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 5.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which start in NZDT(+1300) and switch to NZST(+1200)',
                [[:participant1, '2021-04-04 00:00:00 +1300', '2021-04-04 01:00:00 +1300'],
                 [:participant2, '2021-04-04 01:00:00 +1300', '2021-04-04 02:00:00 +1300'],
                 [:participant3, '2021-04-04 02:00:00 +1300', '2021-04-04 02:00:00 +1200'],
                 [:participant1, '2021-04-04 02:00:00 +1200', '2021-04-04 03:00:00 +1200'],
                 [:participant2, '2021-04-04 03:00:00 +1200', '2021-04-04 04:00:00 +1200']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.hours }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely in NZST(+1200)',
                [[:participant2, '2021-04-04 03:00:00 +1200', '2021-04-04 04:00:00 +1200'],
                 [:participant3, '2021-04-04 04:00:00 +1200', '2021-04-04 05:00:00 +1200'],
                 [:participant1, '2021-04-04 05:00:00 +1200', '2021-04-04 06:00:00 +1200']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('Pacific/Auckland').parse('2021-09-27').beginning_of_day }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely back in NZST(+1300) after 2 timezone switches since the rotation start time',
                [[:participant1, '2021-09-27 00:00:00 +1300', '2021-09-27 01:00:00 +1300'],
                 [:participant2, '2021-09-27 01:00:00 +1300', '2021-09-27 02:00:00 +1300'],
                 [:participant3, '2021-09-27 02:00:00 +1300', '2021-09-27 03:00:00 +1300']]
            end
          end
        end

        context 'with rotation in days' do
          context 'switching to daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('Pacific/Auckland').parse('2020-09-26').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :days, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 4.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which start in NZST(+1200) and switch to NZDT(+1300)',
                [[:participant1, '2020-09-26 00:00:00 +1200', '2020-09-27 00:00:00 +1200'],
                 [:participant2, '2020-09-27 00:00:00 +1200', '2020-09-28 00:00:00 +1300'],
                 [:participant3, '2020-09-28 00:00:00 +1300', '2020-09-29 00:00:00 +1300'],
                 [:participant1, '2020-09-29 00:00:00 +1300', '2020-09-30 00:00:00 +1300']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 3.days }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely in NZDT(+1300)',
                [[:participant1, '2020-09-29 00:00:00 +1300', '2020-09-30 00:00:00 +1300'],
                 [:participant2, '2020-09-30 00:00:00 +1300', '2020-10-01 00:00:00 +1300'],
                 [:participant3, '2020-10-01 00:00:00 +1300', '2020-10-02 00:00:00 +1300']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('Pacific/Auckland').parse('2021-04-07').beginning_of_day }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely back in NZST(+1200) after 2 timezone switches since the rotation start time',
                [[:participant2, '2021-04-07 00:00:00 +1200', '2021-04-08 00:00:00 +1200'],
                 [:participant3, '2021-04-08 00:00:00 +1200', '2021-04-09 00:00:00 +1200'],
                 [:participant1, '2021-04-09 00:00:00 +1200', '2021-04-10 00:00:00 +1200']]
            end
          end

          context 'switching off daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('Pacific/Auckland').parse('2021-04-03').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :days, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 4.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which start in NZDT(+1300) and switch to NZST(+1200)',
                [[:participant1, '2021-04-03 00:00:00 +1300', '2021-04-04 00:00:00 +1300'],
                 [:participant2, '2021-04-04 00:00:00 +1300', '2021-04-05 00:00:00 +1200'],
                 [:participant3, '2021-04-05 00:00:00 +1200', '2021-04-06 00:00:00 +1200'],
                 [:participant1, '2021-04-06 00:00:00 +1200', '2021-04-07 00:00:00 +1200']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 3.days }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely in NZST(+1200)',
                [[:participant1, '2021-04-06 00:00:00 +1200', '2021-04-07 00:00:00 +1200'],
                 [:participant2, '2021-04-07 00:00:00 +1200', '2021-04-08 00:00:00 +1200'],
                 [:participant3, '2021-04-08 00:00:00 +1200', '2021-04-09 00:00:00 +1200']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('Pacific/Auckland').parse('2021-09-28').beginning_of_day }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely back in NZST(+1300) after 2 timezone switches since the rotation start time',
                [[:participant2, '2021-09-28 00:00:00 +1300', '2021-09-29 00:00:00 +1300'],
                 [:participant3, '2021-09-29 00:00:00 +1300', '2021-09-30 00:00:00 +1300'],
                 [:participant1, '2021-09-30 00:00:00 +1300', '2021-10-01 00:00:00 +1300']]
            end
          end
        end

        context 'with rotation in weeks' do
          context 'switching to daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('Pacific/Auckland').parse('2020-09-01').at_noon }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :weeks, length: 2, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 6.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which start in NZST(+1200) and switch to NZDT(+1300)',
                [[:participant1, '2020-09-01 12:00:00 +1200', '2020-09-15 12:00:00 +1200'],
                 [:participant2, '2020-09-15 12:00:00 +1200', '2020-09-29 12:00:00 +1300'],
                 [:participant3, '2020-09-29 12:00:00 +1300', '2020-10-13 12:00:00 +1300']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.weeks }
              let(:ends_at) { starts_at + 4.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely in NZDT(+1300)',
                [[:participant3, '2020-09-29 12:00:00 +1300', '2020-10-13 12:00:00 +1300'],
                 [:participant1, '2020-10-13 12:00:00 +1300', '2020-10-27 12:00:00 +1300']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('Pacific/Auckland').parse('2021-04-18').at_noon }
              let(:ends_at) { starts_at + 5.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely back in NZST(+1200) after 2 timezone switches since the rotation start time',
                [[:participant2, '2021-04-13 12:00:00 +1200', '2021-04-27 12:00:00 +1200'],
                 [:participant3, '2021-04-27 12:00:00 +1200', '2021-05-11 12:00:00 +1200'],
                 [:participant1, '2021-05-11 12:00:00 +1200', '2021-05-25 12:00:00 +1200']]
            end
          end

          context 'switching off daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('Pacific/Auckland').parse('2021-03-21').at_noon }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :weeks, length: 2, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 6.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which start in NZDT(+1300) and switch to NZST(+1200)',
                [[:participant1, '2021-03-21 12:00:00 +1300', '2021-04-04 12:00:00 +1200'],
                 [:participant2, '2021-04-04 12:00:00 +1200', '2021-04-18 12:00:00 +1200'],
                 [:participant3, '2021-04-18 12:00:00 +1200', '2021-05-02 12:00:00 +1200']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.weeks }
              let(:ends_at) { starts_at + 4.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely in NZST(+1200)',
                [[:participant3, '2021-04-18 12:00:00 +1200', '2021-05-02 12:00:00 +1200'],
                 [:participant1, '2021-05-02 12:00:00 +1200', '2021-05-16 12:00:00 +1200']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('Pacific/Auckland').parse('2021-09-30').at_noon }
              let(:ends_at) { starts_at + 5.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely back in NZST(+1200) after 2 timezone switches since the rotation start time',
                [[:participant2, '2021-09-19 12:00:00 +1200', '2021-10-03 12:00:00 +1300'],
                 [:participant3, '2021-10-03 12:00:00 +1300', '2021-10-17 12:00:00 +1300'],
                 [:participant1, '2021-10-17 12:00:00 +1300', '2021-10-31 12:00:00 +1300'],
                 [:participant2, '2021-10-31 12:00:00 +1300', '2021-11-14 12:00:00 +1300']]
            end
          end
        end
      end

      context 'with negative UTC offsets' do
        let_it_be(:schedule) { create(:incident_management_oncall_schedule, timezone: 'America/New_York') }

        context 'with rotation in hours' do
          context 'switching to daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('America/New_York').parse('2021-03-14').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :hours, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 5.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which start in EST(-0500) and switch to EDT(-0400)',
                [[:participant1, '2021-03-14 00:00:00 -0500', '2021-03-14 01:00:00 -0500'],
                 [:participant2, '2021-03-14 01:00:00 -0500', '2021-03-14 02:00:00 -0500'],
                 [:participant3, '2021-03-14 03:00:00 -0400', '2021-03-14 04:00:00 -0400'],
                 [:participant1, '2021-03-14 04:00:00 -0400', '2021-03-14 05:00:00 -0400'],
                 [:participant2, '2021-03-14 05:00:00 -0400', '2021-03-14 06:00:00 -0400']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.hours }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely in EDT(-0400)',
                [[:participant2, '2021-03-14 05:00:00 -0400', '2021-03-14 06:00:00 -0400'],
                 [:participant3, '2021-03-14 06:00:00 -0400', '2021-03-14 07:00:00 -0400'],
                 [:participant1, '2021-03-14 07:00:00 -0400', '2021-03-14 08:00:00 -0400']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('America/New_York').parse('2021-11-08').beginning_of_day }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely back in EST(-0500) after 2 timezone switches since the rotation start time',
                [[:participant1, '2021-11-08 00:00:00 -0500', '2021-11-08 01:00:00 -0500'],
                 [:participant2, '2021-11-08 01:00:00 -0500', '2021-11-08 02:00:00 -0500'],
                 [:participant3, '2021-11-08 02:00:00 -0500', '2021-11-08 03:00:00 -0500']]
            end
          end

          context 'switching off daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('America/New_York').parse('2021-11-07').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :hours, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 5.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which start in EDT(-0400) and switch to EST(-0500)',
                [[:participant1, '2021-11-07 00:00:00 -0400', '2021-11-07 01:00:00 -0400'],
                 [:participant2, '2021-11-07 01:00:00 -0400', '2021-11-07 02:00:00 -0400'],
                 [:participant3, '2021-11-07 02:00:00 -0400', '2021-11-07 02:00:00 -0500'],
                 [:participant1, '2021-11-07 02:00:00 -0500', '2021-11-07 03:00:00 -0500'],
                 [:participant2, '2021-11-07 03:00:00 -0500', '2021-11-07 04:00:00 -0500']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.hours }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely in EST(-0500)',
                [[:participant2, '2021-11-07 03:00:00 -0500', '2021-11-07 04:00:00 -0500'],
                 [:participant3, '2021-11-07 04:00:00 -0500', '2021-11-07 05:00:00 -0500'],
                 [:participant1, '2021-11-07 05:00:00 -0500', '2021-11-07 06:00:00 -0500']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('America/New_York').parse('2022-03-14').beginning_of_day }
              let(:ends_at) { starts_at + 3.hours }

              it_behaves_like 'unsaved shifts',
                'hour-long shifts which are entirely back in EDT(-0400) after 2 timezone switches since the rotation start time',
                [[:participant1, '2022-03-14 00:00:00 -0400', '2022-03-14 01:00:00 -0400'],
                 [:participant2, '2022-03-14 01:00:00 -0400', '2022-03-14 02:00:00 -0400'],
                 [:participant3, '2022-03-14 02:00:00 -0400', '2022-03-14 03:00:00 -0400']]
            end
          end
        end

        context 'with rotation in days' do
          context 'switching to daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('America/New_York').parse('2021-03-13').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :days, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 4.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which start in EST(-0500) and switch to EDT(-0400)',
                [[:participant1, '2021-03-13 00:00:00 -0500', '2021-03-14 00:00:00 -0500'],
                 [:participant2, '2021-03-14 00:00:00 -0500', '2021-03-15 00:00:00 -0400'],
                 [:participant3, '2021-03-15 00:00:00 -0400', '2021-03-16 00:00:00 -0400'],
                 [:participant1, '2021-03-16 00:00:00 -0400', '2021-03-17 00:00:00 -0400']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 3.days }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely in EDT(-0400)',
                [[:participant1, '2021-03-16 00:00:00 -0400', '2021-03-17 00:00:00 -0400'],
                 [:participant2, '2021-03-17 00:00:00 -0400', '2021-03-18 00:00:00 -0400'],
                 [:participant3, '2021-03-18 00:00:00 -0400', '2021-03-19 00:00:00 -0400']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('America/New_York').parse('2021-11-10').beginning_of_day }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely back in EST(-0500) after 2 timezone switches since the rotation start time',
                [[:participant3, '2021-11-10 00:00:00 -0500', '2021-11-11 00:00:00 -0500'],
                 [:participant1, '2021-11-11 00:00:00 -0500', '2021-11-12 00:00:00 -0500'],
                 [:participant2, '2021-11-12 00:00:00 -0500', '2021-11-13 00:00:00 -0500']]
            end
          end

          context 'switching off daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('America/New_York').parse('2021-11-06').beginning_of_day }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :days, length: 1, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 4.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which start in EDT(-0400) and switch to EST(-0500)',
                [[:participant1, '2021-11-06 00:00:00 -0400', '2021-11-07 00:00:00 -0400'],
                 [:participant2, '2021-11-07 00:00:00 -0400', '2021-11-08 00:00:00 -0500'],
                 [:participant3, '2021-11-08 00:00:00 -0500', '2021-11-09 00:00:00 -0500'],
                 [:participant1, '2021-11-09 00:00:00 -0500', '2021-11-10 00:00:00 -0500']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 3.days }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely in EST(-0500)',
                [[:participant1, '2021-11-09 00:00:00 -0500', '2021-11-10 00:00:00 -0500'],
                 [:participant2, '2021-11-10 00:00:00 -0500', '2021-11-11 00:00:00 -0500'],
                 [:participant3, '2021-11-11 00:00:00 -0500', '2021-11-12 00:00:00 -0500']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('America/New_York').parse('2022-03-15').beginning_of_day }
              let(:ends_at) { starts_at + 3.days }

              it_behaves_like 'unsaved shifts',
                'day-long shifts which are entirely back in EDT(-0400) after 2 timezone switches since the rotation start time',
                [[:participant1, '2022-03-15 00:00:00 -0400', '2022-03-16 00:00:00 -0400'],
                 [:participant2, '2022-03-16 00:00:00 -0400', '2022-03-17 00:00:00 -0400'],
                 [:participant3, '2022-03-17 00:00:00 -0400', '2022-03-18 00:00:00 -0400']]
            end
          end
        end

        context 'with rotation in weeks' do
          context 'switching to daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('America/New_York').parse('2021-02-25').at_noon }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :weeks, length: 2, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 6.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which start in EST(-0500) and switch to EDT(-0400)',
                [[:participant1, '2021-02-25 12:00:00 -0500', '2021-03-11 12:00:00 -0500'],
                 [:participant2, '2021-03-11 12:00:00 -0500', '2021-03-25 12:00:00 -0400'],
                 [:participant3, '2021-03-25 12:00:00 -0400', '2021-04-08 12:00:00 -0400']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.weeks }
              let(:ends_at) { starts_at + 4.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely in EDT(-0400)',
                [[:participant3, '2021-03-25 12:00:00 -0400', '2021-04-08 12:00:00 -0400'],
                 [:participant1, '2021-04-08 12:00:00 -0400', '2021-04-22 12:00:00 -0400']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('America/New_York').parse('2021-11-23').at_noon }
              let(:ends_at) { starts_at + 5.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely back in EST(-0500) after 2 timezone switches since the rotation start time',
                [[:participant2, '2021-11-18 12:00:00 -0500', '2021-12-02 12:00:00 -0500'],
                 [:participant3, '2021-12-02 12:00:00 -0500', '2021-12-16 12:00:00 -0500'],
                 [:participant1, '2021-12-16 12:00:00 -0500', '2021-12-30 12:00:00 -0500']]
            end
          end

          context 'switching off daylight savings time' do
            let_it_be(:rotation_start_time) { Time.find_zone('America/New_York').parse('2021-10-26').at_noon }
            let_it_be(:rotation) { create(:incident_management_oncall_rotation, starts_at: rotation_start_time, length_unit: :weeks, length: 2, schedule: schedule) }

            include_context 'with three participants'

            context 'when overlapping the switch' do
              let(:starts_at) { rotation_start_time }
              let(:ends_at) { starts_at + 6.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which start in EDT(-0400) and switch to EST(-0500)',
                [[:participant1, '2021-10-26 12:00:00 -0400', '2021-11-09 12:00:00 -0500'],
                 [:participant2, '2021-11-09 12:00:00 -0500', '2021-11-23 12:00:00 -0500'],
                 [:participant3, '2021-11-23 12:00:00 -0500', '2021-12-07 12:00:00 -0500']]
            end

            context 'starting after switch' do
              let(:starts_at) { rotation_start_time + 4.weeks }
              let(:ends_at) { starts_at + 4.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely in EST(-0500)',
                [[:participant3, '2021-11-23 12:00:00 -0500', '2021-12-07 12:00:00 -0500'],
                 [:participant1, '2021-12-07 12:00:00 -0500', '2021-12-21 12:00:00 -0500']]
            end

            context 'starting after multiple switches' do
              let(:starts_at) { Time.find_zone('America/New_York').parse('2022-03-17').at_noon }
              let(:ends_at) { starts_at + 5.weeks }

              it_behaves_like 'unsaved shifts',
                '2-week-long shifts which are entirely back in EDT(-0400) after 2 timezone switches since the rotation start time',
                [[:participant2, '2022-03-15 12:00:00 -0400', '2022-03-29 12:00:00 -0400'],
                 [:participant3, '2022-03-29 12:00:00 -0400', '2022-04-12 12:00:00 -0400'],
                 [:participant1, '2022-04-12 12:00:00 -0400', '2022-04-26 12:00:00 -0400']]
            end
          end
        end
      end
    end
  end

  describe '#for_timestamp' do
    let(:timestamp) { current_time }

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

        it_behaves_like 'unsaved shift',
          'shift which starts at the same time as the rotation',
          [:participant1, '2020-12-08 00:00:00 UTC', '2020-12-13 00:00:00 UTC']
      end

      context 'when timestamp matches a shift start/end time' do
        let(:timestamp) { rotation_start_time + shift_length }

        it_behaves_like 'unsaved shift',
          'the next shift of the rotation',
          [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
      end

      context 'when timestamp is in the middle of a shift' do
        let(:timestamp) { rotation_start_time + (1.6 * shift_length) }

        it_behaves_like 'unsaved shift',
          'the shift during which the timestamp occurs',
          [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
      end

      context 'when timestamp is at the end of a shift' do
        let(:timestamp) { rotation_start_time + shift_length }

        it_behaves_like 'unsaved shift',
          'the second shift',
          [:participant2, '2020-12-13 00:00:00 UTC', '2020-12-18 00:00:00 UTC']
      end

      context 'with rotation end time' do
        let(:rotation_end_time) { rotation_start_time + (shift_length * 2.5) }

        before do
          rotation.update!(ends_at: rotation_end_time)
        end

        context 'when timestamp matches rotation end time' do
          let(:timestamp) { rotation_end_time }

          it { is_expected.to be_nil }
        end

        context 'when timestamp is before rotation end time' do
          let(:timestamp) { 10.minutes.before(rotation_end_time) }

          it_behaves_like 'unsaved shift',
            'the shift during which the timestamp occurs',
            [:participant3, '2020-12-18 00:00:00 UTC', '2020-12-20 12:00:00 UTC']
        end

        context 'when timestamp is at rotation end time' do
          let(:timestamp) { 10.minutes.after(rotation_end_time) }

          it { is_expected.to be_nil }
        end
      end

      context 'with shift active period times set' do
        before do
          rotation.update!(
            active_period_start: "08:00",
            active_period_end: "17:00"
          )
        end

        context 'when timestamp is the start of rotation, but before active period' do
          let(:timestamp) { rotation_start_time }

          it { is_expected.to be_nil }
        end

        context 'when timestamp is the same time as active period start' do
          let(:timestamp) { rotation_start_time.change(hour: 8) }

          it_behaves_like 'unsaved shift',
            'the first shift of the shift cycle (split by the active period)',
            [:participant1, '2020-12-08 08:00:00 UTC', '2020-12-08 17:00:00 UTC']
        end

        context 'when timestamp is the same time as active period end' do
          let(:timestamp) { rotation_start_time.change(hour: 17) }

          it { is_expected.to be_nil }
        end

        context 'when timestamp is the after the active period ends' do
          let(:timestamp) { rotation_start_time.change(hour: 17, min: 1) }

          it { is_expected.to be_nil }
        end
      end
    end
  end
end
