# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::PendingEscalations::ProcessService do
  let_it_be(:project) { create(:project) }
  let_it_be(:schedule_1) { create(:incident_management_oncall_schedule, :with_rotation, project: project) }
  let_it_be(:schedule_2) { create(:incident_management_oncall_schedule, :with_rotation, project: project) }
  let_it_be(:schedule_1_users) { schedule_1.participants.map(&:user) }
  let_it_be(:schedule_2_users) { schedule_2.participants.map(&:user) }

  let(:escalation_rule) { build(:incident_management_escalation_rule, oncall_schedule: schedule_1 ) }
  let!(:escalation_policy) { create(:incident_management_escalation_policy, project: project, rules: [escalation_rule]) }

  let(:alert) { create(:alert_management_alert, project: project, **alert_params) }
  let(:alert_params) { { status: AlertManagement::Alert::STATUSES[:triggered] } }

  let(:target) { alert }
  let(:escalation) { create(:incident_management_pending_alert_escalation, rule: escalation_rule, oncall_schedule: schedule_1, target: target, status: IncidentManagement::EscalationRule.statuses[:acknowledged]) }

  let(:service) { described_class.new(escalation) }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
    stub_feature_flags(escalation_policies_mvc: project)
  end

  describe '#execute' do
    subject(:execute) { service.execute }

    shared_examples 'it does not escalate' do
      it_behaves_like 'does not send on-call notification'

      it 'does not delete the escalation' do
        subject
        expect { escalation.reload }.not_to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    shared_examples 'it escalates' do
      it_behaves_like 'sends on-call notification'

      it 'deletes the escalation' do
        subject
        expect { escalation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'all conditions are met' do
      let(:users) { schedule_1_users }

      it_behaves_like 'it escalates'

      context 'feature flag is off' do
        before do
          stub_feature_flags(escalation_policies_mvc: false)
        end

        it_behaves_like 'it does not escalate'
      end
    end

    context 'target is already resolved' do
      let(:target) { create(:alert_management_alert, :resolved, project: project) }

      it_behaves_like 'does not send on-call notification'

      it 'deletes the escalation' do
        subject
        expect { escalation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'target status is not above threshold' do
      let(:target) { create(:alert_management_alert, :acknowledged, project: project) }

      it_behaves_like 'it does not escalate'
    end
  end
end
