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
        let(:notification_args) do
          [
            [participant.user],
            having_attributes(class: AlertManagement::Alert, fingerprint: fingerprint)
          ]
        end

        it_behaves_like 'Alert Notification Service sends notification email to on-call users'
      end
    end
  end
end
