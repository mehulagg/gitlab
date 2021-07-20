# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::AlertCheckWorker do
  let(:worker) { described_class.new }

  let_it_be(:escalation) { create(:incident_management_pending_alert_escalation) }

  describe '#perform' do
    subject { worker.perform(escalation.id) }

    it 'processes the escalation' do
      process_service = spy(IncidentManagement::PendingEscalations::ProcessService)

      expect(IncidentManagement::PendingEscalations::ProcessService).to receive(:new).with(escalation).and_return(process_service)
      subject
      expect(process_service).to have_received(:execute)
    end
  end
end
