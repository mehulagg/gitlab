# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotations::RemoveParticipantService do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:rotation) { create(:incident_management_oncall_rotation, schedule: schedule) }
  let_it_be(:participant) { create(:incident_management_oncall_participant, rotation: rotation, user: user) }

  let(:service) { described_class.new(rotation, user) }

  subject(:execute) { service.execute }

  before do
    stub_licensed_features(oncall_schedules: true)
  end

  context 'user is not a participant' do
    let(:other_user) { create(:user) }
    let(:service) { described_class.new(rotation, other_user) }

    it 'does not send a notification' do
      expect(NotificationService).not_to receive(:oncall_user_removed)
      execute
    end
  end

  it 'marks the participant as removed' do
    expect { execute }.to change { participant.reload.is_removed }.to(true)
  end

  context 'with existing shifts and during a current shift' do
    let(:current_date) { 8.days.after(rotation.starts_at) }
    let!(:existing_shift) do
      IncidentManagement::OncallRotations::PersistShiftsJob.new.perform(rotation.id)

      rotation.shifts.last!
    end

    around do |example|
      travel_to(current_date) { example.run }
    end

    it 'ends the current shift, and does not affect previous shifts' do
      expect { execute }.not_to change { existing_shift.reload }

      current_shift = rotation.shifts.reload.last

      expect(current_shift.ends_at).to eq(Time.current)
    end
  end

  context 'rotation with another participant' do
    let_it_be(:second_participant) { create(:incident_management_oncall_participant, rotation: rotation) }

    context 'when other participant has a current shift' do
      # Move current date so current shift will be the second participant
      let(:current_date) { rotation.shift_cycle_duration.after(rotation.starts_at) }

      around do |example|
        travel_to(current_date) { example.run }
      end

      it 'does not cut the current shift' do
        execute

        current_shift = rotation.shifts.reload.last

        expect(current_shift.participant).to eq(second_participant)
        expect(current_shift.ends_at).to be_like_time(rotation.shift_cycle_duration.after(current_shift.starts_at))
      end
    end
  end
end
