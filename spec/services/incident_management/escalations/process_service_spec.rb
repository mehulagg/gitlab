# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::Escalations::ProcessService do
  let_it_be(:project) { create(:project) }

  let(:escalation_policy) { create(:incident_management_escalation_policy, project: project) }
  let(:oncall_schedule) { escalation_policy.rules.first.oncall_schedule }
  let!(:oncall_rotation) { create(:incident_management_oncall_rotation, :with_participants, schedule: oncall_schedule) }

  let(:alert) { create(:alert_management_alert, project: project, **alert_params) }
  let(:alert_params) { { status: AlertManagement::Alert::STATUSES[:triggered] } }

  let(:escalation) { create(:incident_management_alert_escalation, policy: escalation_policy, alert: alert, **escalation_params) }
  let(:escalation_params) { { created_at: 10.minutes.ago, updated_at: 10.minutes.ago } }

  let(:service) { described_class.new(escalation) }

  before do
    stub_licensed_features(oncall_schedules: true, escalation_policies: true)
    stub_feature_flags(escalation_policies_mvc: project)
  end

  describe '#execute' do
    subject(:execute) { service.execute }

    shared_examples 'it does not escalate' do
      it_behaves_like 'does not send on-call notification'

      specify do
        expect { subject }.not_to change(escalation, :updated_at)
      end
    end

    context 'all conditions are met' do
      # Elapsed time of escalation, longer than rule limit
      it_behaves_like 'sends on-call notification'

      it 'updates the escalation time' do
        expect { subject }.to change(escalation, :updated_at)
      end

      context 'feature flag is off' do
        before do
          stub_feature_flags(escalation_policies_mvc: false)
        end

        it_behaves_like 'it does not escalate'
      end
    end

    context 'zero min escalation rule' do
      # TODO setup rule with 0 value for elapsed_time_seconds
      it 'escalates';

      context 'rule previously escalated' do
        let(:escalation_params) { { updated_at: 1.second.from_now } }

        it_behaves_like 'it does not escalate'
      end
    end

    context 'multiple rules' do
      # Setup rules
      context 'time between rules' do
        it 'does not escalate';
      end

      context 'time past second rule' do
        it 'escalates second rule';
      end

      context 'second rule status not valid' do
        it 'does not escalate';
      end
    end

    describe 'non-escalate conditions' do
      context 'alert status not valid' do
        let(:alert_params) { { status: AlertManagement::Alert::STATUSES[:acknowledged] } }

        it_behaves_like 'it does not escalate'
      end

      context 'not enough time elapsed' do
        let(:escalation_params) { { created_at: Time.current, updated_at: Time.current } }

        it_behaves_like 'it does not escalate'
      end

      context 'rule previously escalated' do
        let(:escalation_params) { { created_at: 10.minutes.from_now, updated_at: 10.minutes.from_now } }

        it_behaves_like 'it does not escalate'
      end
    end
  end
end
