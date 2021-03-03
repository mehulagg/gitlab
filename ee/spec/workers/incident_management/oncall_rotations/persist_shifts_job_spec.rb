# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotations::PersistShiftsJob do
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
    end
  end
end
