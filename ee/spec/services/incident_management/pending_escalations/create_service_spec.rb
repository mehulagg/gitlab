# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::CreateService do
  let_it_be(:project) { create(:project) }
  let_it_be(:target) { create(:alert_management_alert, project: project) }
  let_it_be(:rule_count) { 2 }

  let!(:escalation_policy) { create(:incident_management_escalation_policy, project: project, rule_count: rule_count) }
  let(:rules) { escalation_policy.rules }

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

      first_escalation, second_escalation = target.pending_escalations.order(created_at: :asc)
      first_rule, second_rule = rules

      expect_escalation_attributes_with(escalation: first_escalation, target: target, rule: first_rule)
      expect_escalation_attributes_with(escalation: second_escalation, target: target, rule: second_rule)
    end

    context 'when there is no escalation policy for the project' do
      let!(:escalation_policy) { nil }

      it 'does nothing' do
        expect { execute }.not_to change { IncidentManagement::PendingEscalations::Alert.count }
      end
    end

    it 'creates the escalations and queues the escalation process check' do
      expect(IncidentManagement::PendingEscalations::AlertCheckWorker)
        .to receive(:bulk_perform_async)
        .with([[a_kind_of(Integer)], [a_kind_of(Integer)]])

      expect { execute }.to change { IncidentManagement::PendingEscalations::Alert.count }.by(rule_count)
    end

    context 'when reset time is provided' do
      let!(:later_escalation_rule) { create(:incident_management_escalation_rule, project: project, policy: escalation_policy, elapsed_time_seconds: 10.minutes) }

      let(:service) { described_class.new(target, reset_time: 7.minutes.from_now) }

      it 'creates an escalation for each rule for the policy' do
        expect { execute }.to change { IncidentManagement::PendingEscalations::Alert.count }.by(1)

        escalation = target.pending_escalations.last

        expect_escalation_attributes_with(escalation: escalation, target: target, rule: later_escalation_rule)
      end
    end

    def expect_escalation_attributes_with(escalation:, target:, rule:)
      expect(escalation).to have_attributes(
        rule_id: rule.id,
        alert_id: target.id,
        process_at: rule.elapsed_time_seconds.seconds.after(target.triggered_at)
      )
    end
  end
end
