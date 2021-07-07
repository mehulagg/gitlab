# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::EscalationRulesFinder do
  let_it_be(:project) { create(:project) }
  let_it_be(:policy) { create(:incident_management_escalation_policy, project: project) }
  let_it_be(:escalation_rule) { policy.rules.first }
  let_it_be(:escalation_rule_earlier) { create(:incident_management_escalation_rule, project: project, policy: policy, elapsed_time_seconds: 1.minute) }
  let_it_be(:escalation_rule_from_another_project) { create(:incident_management_escalation_rule) }

  let(:params) { {} }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
  end

  describe '#execute' do
    subject(:execute) { described_class.new(project, params).execute }

    it 'returns project escalation rules from first policy' do
      is_expected.to contain_exactly(escalation_rule, escalation_rule_earlier)
    end

    context 'when min_elapsed_time given' do
      let(:params) { { min_elapsed_time: 2.minutes } }

      it { is_expected.to contain_exactly(escalation_rule) }
    end
  end
end
