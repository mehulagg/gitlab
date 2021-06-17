# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::CreateService do
  let_it_be(:project) { create(:project) }
  let_it_be(:target) { create(:alert_management_alert, project: project) }
  let_it_be(:rule_count) { 2 }
  let_it_be(:escalation_policy) { create(:incident_management_escalation_policy, project: project, rule_count: rule_count) }

  let(:service) { described_class.new(target) }

  subject(:execute) { service.execute }

  context 'feature not available' do
    it 'does nothing' do
      expect { execute }.not_to change { IncidentManagement::PendingEscalations::Alert.count }
    end
  end

  context 'feature available' do
    before do
      stub_licensed_features(oncall_schedules: true, escalation_policies: true)
      stub_feature_flags(escalation_policies_mvc: project)
    end

    context 'target is resolved' do
      let(:target) { create(:alert_management_alert, :resolved, project: project) }

      it 'does nothing' do
        expect { execute }.not_to change { IncidentManagement::PendingEscalations::Alert.count }
      end
    end

    it 'creates an escalation for each rule for the policy' do
      expect { execute }.to change { IncidentManagement::PendingEscalations::Alert.count }.by(rule_count)
    end

    context 'zero-min escalation rule' do
      let_it_be(:first_escalation_rule) do
        rule = escalation_policy.rules.first
        rule.update!(elapsed_time_seconds: 0)

        rule
      end

      let(:process_service_spy) { spy('IncidentManagement::PendingEscalations::ProcessService') }

      it 'processes the escalation' do
        expect(IncidentManagement::PendingEscalations::ProcessService)
          .to receive(:new)
          .with(having_attributes(rule_id: first_escalation_rule.id))
          .and_return(process_service_spy)

        expect(process_service_spy).to receive(:execute)

        expect { execute }.to change { IncidentManagement::PendingEscalations::Alert.count }.by(rule_count)
      end
    end
  end
end
