# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallRotations::PersistAllRotationsShiftsJob do
  let(:worker) { described_class.new }

  let_it_be(:schedule) { create(:incident_management_oncall_schedule) }

  let_it_be(:rotation) { create(:incident_management_oncall_rotation, :with_participant, schedule: schedule) }
  let_it_be(:rotation_2) { create(:incident_management_oncall_rotation, :with_participant, schedule: schedule) }
  let_it_be(:not_started_rotation) { create(:incident_management_oncall_rotation, :with_participant, schedule: schedule, starts_at: 1.day.from_now) }

  describe '.perform' do
    subject(:perform) { worker.perform }

    it 'creates a PersistOncallShiftsJob for each started rotation' do
      expect(::IncidentManagement::OncallRotations::PersistShiftsJob).to receive(:perform_async).with(rotation.id)
      expect(::IncidentManagement::OncallRotations::PersistShiftsJob).to receive(:perform_async).with(rotation_2.id)
      expect(::IncidentManagement::OncallRotations::PersistShiftsJob).not_to receive(:perform_async).with(not_started_rotation.id)

      perform
    end
  end
end
