# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Alerting::NotifyService do
  let_it_be(:project, refind: true) { create(:project) }

  describe '#execute' do
    let_it_be(:integration) { create(:alert_management_http_integration, project: project) }

    let(:service) { described_class.new(project, payload) }
    let(:token) { integration.token }
    let(:payload) do
      {
        'title' => 'Test alert title'
      }
    end

    subject { service.execute(token, integration) }

    context 'existing alert with same payload fingerprint' do
      let(:existing_alert) { create(:alert_management_alert, :from_payload, project: project, payload: payload) }

      before do
        stub_licensed_features(generic_alert_fingerprinting: fingerprinting_enabled)
        existing_alert # create existing alert after enabling flag
      end

      context 'generic fingerprinting license not enabled' do
        let(:fingerprinting_enabled) { false }

        it 'creates AlertManagement::Alert' do
          expect { subject }.to change(AlertManagement::Alert, :count)
        end

        it 'does not increment the existing alert count' do
          expect { subject }.not_to change { existing_alert.reload.events }
        end
      end

      context 'generic fingerprinting license enabled' do
        let(:fingerprinting_enabled) { true }

        it 'does not create AlertManagement::Alert' do
          expect { subject }.not_to change(AlertManagement::Alert, :count)
        end

        it 'increments the existing alert count' do
          expect { subject }.to change { existing_alert.reload.events }.from(1).to(2)
        end

        context 'end_time provided for subsequent alert' do
          let(:existing_alert) { create(:alert_management_alert, :from_payload, project: project, payload: payload.except('end_time')) }
          let(:payload) { { 'title' => 'title', 'end_time' => Time.current.change(usec: 0).iso8601 } }

          it 'does not create AlertManagement::Alert' do
            expect { subject }.not_to change(AlertManagement::Alert, :count)
          end

          it 'resolves the existing alert', :aggregate_failures do
            expect { subject }.to change { existing_alert.reload.resolved? }.from(false).to(true)
            expect(existing_alert.ended_at).to eq(payload['end_time'])
          end
        end
      end
    end

    context 'with on-call schedules' do
      let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
      let_it_be(:rotation) { create(:incident_management_oncall_rotation, schedule: schedule) }
      let_it_be(:participant) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
      let_it_be(:fingerprint) { 'fingerprint' }
      let_it_be(:gitlab_fingerprint) { Digest::SHA1.hexdigest(fingerprint) }

      let(:payload) { { 'fingerprint' => fingerprint } }
      let(:users) { [participant.user] }

      before do
        stub_licensed_features(oncall_schedules: project)
      end

      include_examples 'oncall users are correctly notified of firing alert'

      context 'with resolving payload' do
        let(:payload) do
          {
            'fingerprint' => fingerprint,
            'end_time' => Time.current.iso8601
          }
        end

        include_examples 'oncall users are correctly notified of recovery alert'
      end

      context 'with escalation policies ready' do
        let_it_be(:policy) { create(:incident_management_escalation_policy, project: project) }

        before do
          stub_licensed_features(oncall_schedules: project, escalation_policies: true)
        end

        it_behaves_like 'does not send on-call notification'
        include_examples 'creates an escalation'

        context 'existing alert with same payload fingerprint' do
          let_it_be(:alert) { create(:alert_management_alert, fingerprint: gitlab_fingerprint, project: project) }
          let_it_be(:pending_escalation) { create(:incident_management_pending_alert_escalation, alert: alert) }

          it 'does not create an escalation' do
            expect { subject }.not_to change { alert.pending_escalations.count }
          end

          context 'with resolving payload' do
            let(:payload) do
              {
                'fingerprint' => fingerprint,
                'end_time' => Time.current.iso8601
              }
            end

            context 'with existing alert escalation' do
              let_it_be(:pending_escalation) { create(:incident_management_pending_alert_escalation, alert: alert) }

              let(:target) { alert }

              include_examples "deletes the target's escalations"
            end
          end
        end
      end
    end
  end
end
