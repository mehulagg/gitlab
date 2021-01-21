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
      let(:notification_service) { spy }

      context 'with oncall schedules enabled' do
        before do
          stub_licensed_features(oncall_schedules: project)
        end

        it 'sends a notification email to all users oncall' do
          expect(NotificationService).to receive(:new).and_return(notification_service)

          expect(notification_service).to receive_message_chain(:async, :notify_oncall_users_of_alert).with(
            [participant.user],
            having_attributes(class: AlertManagement::Alert, title: payload['title'])
          )
          expect(subject).to be_success
        end

        it 'does not have an N+1 for fetching users' do
          subject # Initial serivce request has many additional requests

          query_count = ActiveRecord::QueryRecorder.new { described_class.new(project.reload, payload).execute(token, integration) }

          new_rotation = create(:incident_management_oncall_rotation, schedule: schedule)
          create(:incident_management_oncall_participant, :with_developer_access, rotation: new_rotation)

          expect { described_class.new(project.reload, payload).execute(token, integration) }.not_to exceed_query_limit(query_count)
        end
      end

      context 'with oncall schedules disabled' do
        it 'does not notify the on-call users' do
          expect(NotificationService).not_to receive(:new)

          expect(subject).to be_success
        end
      end
    end
  end
end
