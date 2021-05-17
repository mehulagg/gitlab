# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::CreateOrchestrationPolicyWorker do
  describe '#perform' do
    let_it_be(:configuration) { create(:security_orchestration_policy_configuration) }
    let_it_be(:schedule) { create(:security_orchestration_policy_rule_schedule, security_orchestration_policy_configuration: configuration) }

    before do
      allow_next_instance_of(Repository) do |repository|
        allow(repository).to receive(:blob_data_at).and_return({ scan_execution_policy: active_policies }.to_yaml)
      end
    end

    subject(:worker) { described_class.new }

    context 'when policy is valid' do
      let(:active_policies) do
        [
          {
            name: 'Scheduled DAST 1',
            description: 'This policy runs DAST for every 20 mins',
            enabled: true,
            rules: [{ type: 'schedule', branches: %w[production], cadence: '*/20 * * * *' }],
            actions: [
              { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
            ]
          },
          {
            name: 'Scheduled DAST 2',
            description: 'This policy runs DAST for every 20 mins',
            enabled: true,
            rules: [{ type: 'schedule', branches: %w[production], cadence: '*/20 * * * *' }],
            actions: [
              { scan: 'dast', site_profile: 'Site Profile', scanner_profile: 'Scanner Profile' }
            ]
          }
        ]
      end

      it 'executes the process rule service' do
        active_policies.each_with_index do |policy, policy_index|
          expect_next_instance_of(Security::SecurityOrchestrationPolicies::ProcessRuleService,
                                  policy_configuration: configuration, policy_index: policy_index, policy: policy) do |service|
            expect(service).to receive(:execute)
          end
        end

        expect { worker.perform }.not_to change(Security::OrchestrationPolicyRuleSchedule, :count)
      end
    end

    context 'when policy is invalid' do
      let(:active_policies) do
        [
          {
            key: 'invalid',
            label: 'invalid'
          }
        ]
      end

      it 'does not execute process rule service' do
        expect(Security::SecurityOrchestrationPolicies::ProcessRuleService).not_to receive(:new)

        expect { worker.perform }.to change(Security::OrchestrationPolicyRuleSchedule, :count).by(-1)
      end
    end
  end
end
