# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::AlertCreateWorker do
  let(:worker) { described_class.new }

  let_it_be(:alert) { create(:alert_management_alert) }

  describe '#perform' do
    let(:args) { [alert.id] }

    subject { worker.perform(*args) }

    it 'processes the escalation' do
      expect_next_instance_of(IncidentManagement::PendingEscalations::CreateService, alert) do |service|
        expect(service).to receive(:execute)
      end

      subject
    end

    context 'without valid alert' do
      let(:args) { [non_existing_record_id] }

      it 'does nothing' do
        expect(IncidentManagement::PendingEscalations::CreateService).not_to receive(:new)
        expect { subject }.not_to raise_error
      end
    end
  end
end
