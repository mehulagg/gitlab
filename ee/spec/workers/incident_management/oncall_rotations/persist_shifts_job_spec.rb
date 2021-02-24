# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotations::PersistShiftsJob do
  include OncallHelpers

  let(:worker) { described_class.new }
  let(:rotation_id) { rotation.id }

  before do
    stub_licensed_features(oncall_schedules: true)
  end

  describe '#perform' do
    subject(:perform) { worker.perform(rotation_id) }

    context 'unknown rotation' do
      let(:rotation_id) { non_existing_record_id }

      it { is_expected.to be_nil }

      it 'does not create shifts' do
        expect { perform }.not_to change { IncidentManagement::OncallShift.count }
      end
    end

    context 'when rotation has no saved shifts' do
      context 'and rotation was created before it "started"' do
        let_it_be(:rotation) { create(:incident_management_oncall_rotation, :with_participant, created_at: 1.day.ago) }

        it 'creates shift' do
          expect { perform }.to change { rotation.shifts.count }.by(1)
          expect(rotation.shifts.first.starts_at).to eq(rotation.starts_at)
        end
      end

      context 'and rotation "started" before it was created' do
        let_it_be(:rotation) { create(:incident_management_oncall_rotation, :with_participant, starts_at: 1.month.ago) }

        it 'creates shift without backfilling' do
          expect { perform }.to change { rotation.shifts.count }.by(1)

          first_shift = rotation.shifts.first

          expect(first_shift.starts_at).to be > rotation.starts_at
          expect(rotation.created_at).to be_between(first_shift.starts_at, first_shift.ends_at)
        end
      end

      context 'and rotation with active period is updated to start in the past instead of the future while no shifts are in progress' do
        let_it_be(:sunday) { Time.current.beginning_of_week }
        let_it_be(:created_at) { sunday.change(hour: 5) }
        let_it_be(:updated_at) { sunday.next_week(:thursday).change(hour: 6) }
        let_it_be(:starts_at) { sunday.next_week(:monday).beginning_of_day }
        let_it_be(:rotation) do
          # Mimic start time update. Imagine the old value was Friday @ 00:00.
          create(
            :incident_management_oncall_rotation,
            :with_active_period,
            :with_participant,
            starts_at: starts_at,
            created_at: created_at,
            updated_at: updated_at
          )
        end
        let(:active_period) { active_period_for_date_with_tz(updated_at, rotation) }

        around do |example|
          travel_to(current_time) { example.run }
        end

        context 'before the next shift has started' do
          let(:current_time) { 1.minute.before(active_period[0]) }

          it 'does not create shifts' do
            expect { perform }.not_to change { IncidentManagement::OncallShift.count }
          end
        end

        context 'once the next shift has started' do
          let(:current_time) { active_period[0] }

          it 'creates only the next shift' do
            expect { perform }.to change { rotation.shifts.count }.by(1)
            expect(rotation.shifts.first.starts_at).to eq(active_period[0])
            expect(rotation.shifts.first.ends_at).to eq(active_period[1])
          end
        end
      end
    end

    context 'when rotation has saved shifts' do
      let_it_be(:existing_shift) { create(:incident_management_oncall_shift) }
      let_it_be(:rotation) { existing_shift.rotation }

      context 'when current time is during a saved shift' do
        it 'does not create shifts' do
          expect { perform }.not_to change { IncidentManagement::OncallShift.count }
        end
      end

      context 'when current time is not during a saved shift' do
        around do |example|
          travel_to(5.minutes.after(existing_shift.ends_at)) { example.run }
        end

        it 'creates shift' do
          expect { perform }.to change { rotation.shifts.count }.by(1)
          expect(rotation.shifts.first).to eq(existing_shift)
          expect(rotation.shifts.second.starts_at).to eq(existing_shift.ends_at)
        end
      end

      # Unexpected case. If the job is delayed, we'll still
      # fill in the correct shift history.
      context 'when current time is several shifts after the last saved shift' do
        around do |example|
          travel_to(existing_shift.ends_at + (3 * rotation.shift_cycle_duration)) { example.run }
        end

        context 'when feature flag is not enabled' do
          before do
            stub_feature_flags(oncall_schedules_mvc: false)
          end

          it 'does not create shifts' do
            expect { perform }.not_to change { IncidentManagement::OncallShift.count }
          end
        end

        it 'creates multiple shifts' do
          expect { perform }.to change { rotation.shifts.count }.by(3)

          first_shift,
          second_shift,
          third_shift,
          fourth_shift = rotation.shifts.order(:starts_at)

          expect(rotation.shifts.length).to eq(4)
          expect(first_shift).to eq(existing_shift)
          expect(second_shift.starts_at).to eq(existing_shift.ends_at)
          expect(third_shift.starts_at).to eq(existing_shift.ends_at + rotation.shift_cycle_duration)
          expect(fourth_shift.starts_at).to eq(existing_shift.ends_at + (2 * rotation.shift_cycle_duration))
        end
      end

      context 'when rotation has active periods' do
        let_it_be(:starts_at) { Time.current.beginning_of_day }
        let_it_be(:rotation) do
          create(
            :incident_management_oncall_rotation,
            :with_participant,
            :with_active_period,
            starts_at: starts_at
           )
        end

        let(:active_period) { active_period_for_date_with_tz(starts_at, rotation) }
        let_it_be(:existing_shift) do
          create(
            :incident_management_oncall_shift,
            rotation: rotation,
            participant: rotation.participants.first,
            starts_at: active_period[0],
            ends_at: active_period[1]
          )
        end

        context 'when current time is in the active period' do
          around do |example|
            travel_to(1.3.days.after(existing_shift.starts_at)) { example.run }
          end

          it 'creates the next shift' do
            expect { perform }.to change { rotation.shifts.count }.by(1)
            expect(rotation.shifts.first).to eq(existing_shift)
            expect(rotation.shifts.second.starts_at).to eq(1.day.after(existing_shift.starts_at))
            expect(rotation.shifts.second.ends_at).to eq(1.day.after(existing_shift.ends_at))
          end
        end

        context 'when the current time is not in the active period' do
          around do |example|
            travel_to(Time.current.beginning_of_day) { example.run }
          end

          it 'does not create shifts' do
            expect { perform }.not_to change { IncidentManagement::OncallShift.count }
          end
        end
      end

      context 'when rotation is updated to start in the later' do
        # do not backfill things
      end
    end
  end
end
