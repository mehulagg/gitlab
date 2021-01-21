# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::ProcessPrometheusAlertService do
  let_it_be(:project, refind: true) { create(:project) }

  before do
    allow(ProjectServiceWorker).to receive(:perform_async)
  end

  describe '#execute' do
    let(:service) { described_class.new(project, payload) }

    subject(:execute) { service.execute }

    context 'when alert payload is valid' do
      let(:parsed_payload) { Gitlab::AlertManagement::Payload.parse(project, payload, monitoring_tool: 'Prometheus') }
      let(:fingerprint) { parsed_payload.gitlab_fingerprint }
      let(:payload) do
        {
          'status' => 'firing',
          'labels' => { 'alertname' => 'GitalyFileServerDown' },
          'annotations' => { 'title' => 'Alert title' },
          'startsAt' => '2020-04-27T10:10:22.265949279Z',
          'generatorURL' => 'http://8d467bd4607a:9090/graph?g0.expr=vector%281%29&g0.tab=1'
        }
      end

      context 'with on-call schedule' do
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
              having_attributes(class: AlertManagement::Alert, fingerprint: fingerprint)
            )
            expect(subject).to be_success
          end

          it 'does have an N+1 for fetching users' do
            subject # Initial service load includes a few additional queries

            query_count = ActiveRecord::QueryRecorder.new { described_class.new(project.reload, payload).execute }

            new_rotation = create(:incident_management_oncall_rotation, schedule: schedule)
            create(:incident_management_oncall_participant, :with_developer_access, rotation: new_rotation)

            expect { described_class.new(project.reload, payload).execute }.not_to exceed_query_limit(query_count)
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
end
