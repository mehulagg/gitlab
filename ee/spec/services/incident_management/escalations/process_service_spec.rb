# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::Escalations::ProcessService do
  let_it_be(:project) { create(:project) }
  let_it_be(:schedule_1) { create(:incident_management_oncall_schedule, :with_rotation, project: project) }
  let_it_be(:schedule_2) { create(:incident_management_oncall_schedule, :with_rotation, project: project) }

  let_it_be(:rules) { [build(:incident_management_escalation_rule, oncall_schedule: schedule_1)] }
  let_it_be(:escalation_policy) { create(:incident_management_escalation_policy, project: project, rules: rules) }

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
        expect { subject }.to change(escalation, :updated_at)
      end
    end

    shared_examples 'it escalates' do
      it_behaves_like 'sends on-call notification'

      it 'updates the escalation time' do
        expect { subject }.to change(escalation, :updated_at)
      end
    end

    context 'all conditions are met' do
      let(:users) { potential_oncall_users_for_rule(rules.first) }

      it_behaves_like 'it escalates'

      context 'feature flag is off' do
        before do
          stub_feature_flags(escalation_policies_mvc: false)
        end

        it_behaves_like 'does not send on-call notification'

        it 'does not update the escalation' do
          expect { subject }.not_to change(escalation, :updated_at)
        end
      end
    end

    context 'zero min escalation rule' do
      let(:rule) { build(:incident_management_escalation_rule, oncall_schedule: schedule_1, status: AlertManagement::Alert::STATUSES[:acknowledged], elapsed_time_seconds: 0) }
      let(:rules) { [rule] }
      let(:escalation_policy) { create(:incident_management_escalation_policy, project: project, rules: rules) }
      let(:escalation_params) { { created_at: Time.current, updated_at: Time.current } }
      let(:users) { potential_oncall_users_for_rule(rule) }

      it_behaves_like 'it escalates'

      context 'rule previously escalated' do
        let(:escalation_params) { { updated_at: 1.second.from_now } }

        it_behaves_like 'it does not escalate'
      end
    end

    context 'multiple rules' do
      let(:rule_1) { build(:incident_management_escalation_rule, oncall_schedule: schedule_1, status: AlertManagement::Alert::STATUSES[:acknowledged], elapsed_time_seconds: 5.minutes) }
      let(:rule_2) { build(:incident_management_escalation_rule, oncall_schedule: schedule_2, status: AlertManagement::Alert::STATUSES[:resolved], elapsed_time_seconds: 10.minutes) }
      let(:escalation_policy) { create(:incident_management_escalation_policy, project: project, rules: [rule_1, rule_2]) }

      context 'time between rules' do
        let(:escalation_params) { { created_at: 7.minutes.ago, updated_at: 1.minute.ago } }

        it_behaves_like 'it does not escalate'
      end

      context 'time past second rule' do
        let(:escalation_params) { { created_at: rule_2.elapsed_time_seconds.seconds.ago, updated_at: rule_1.elapsed_time_seconds.seconds.ago } }
        let(:users) { potential_oncall_users_for_rule(rule_2) + potential_oncall_users_for_rule(rule_1) }

        it 'escalates both escalation rules' do
          notification_async = double(NotificationService::Async)
          allow(NotificationService).to receive_message_chain(:new, :async).and_return(notification_async)

          expect(notification_async).to receive(:notify_oncall_users_of_alert).with(
            potential_oncall_users_for_rule(rule_1),
            alert
          ).once

          expect(notification_async).to receive(:notify_oncall_users_of_alert).with(
            potential_oncall_users_for_rule(rule_2),
            alert
          ).once

          execute
        end

        context 'second rule status not valid' do
          let(:alert_params) { { status: AlertManagement::Alert::STATUSES[:resolved], ended_at: Time.current } }

          it_behaves_like 'it does not escalate'
        end
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

    def potential_oncall_users_for_rule(rule)
      rule.oncall_schedule.rotations.map(&:users).flatten
    end
  end
end
