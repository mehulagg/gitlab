# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::AlertCreateWorker do
  let(:worker) { described_class.new }

  let_it_be(:alert) { create(:alert_management_alert) }

  describe '#perform' do
    let(:args) { [alert.id] }

    subject { worker.perform(*args) }

    it 'processes the escalation' do
      create_service = spy(IncidentManagement::PendingEscalations::CreateService)

      expect(IncidentManagement::PendingEscalations::CreateService).to receive(:new).with(alert).and_return(create_service)
      subject
      expect(create_service).to have_received(:execute)
    end

    context 'with service kwargs' do
      let(:args) { [alert.id, { reset_time: Time.current }] }

      it 'processes the escalation' do
        create_service = spy(IncidentManagement::PendingEscalations::CreateService)

        expect(IncidentManagement::PendingEscalations::CreateService).to receive(:new).with(alert, args.last).and_return(create_service)
        subject
        expect(create_service).to have_received(:execute)
      end
    end
  end
end
