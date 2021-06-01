# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::Escalations::ScheduleEscalationCheckCronWorker do
  let(:worker) { described_class.new }

  let_it_be(:escalation_1) { create(:incident_management_alert_escalation) }
  let_it_be(:escalation_2) { create(:incident_management_alert_escalation) }

  describe '#perform' do
    subject { worker.perform }

    it 'schedules a job for each escalaton' do
      expect(IncidentManagement::Escalations::EscalationCheckWorker).to receive(:perform_async).with(escalation_1.class.name, escalation_1.id)
      expect(IncidentManagement::Escalations::EscalationCheckWorker).to receive(:perform_async).with(escalation_2.class.name, escalation_2.id)

      subject
    end
  end
end
