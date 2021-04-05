# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::ProcessPrometheusAlertService do
  let_it_be(:project, refind: true) { create(:project) }

  let(:service) { described_class.new(project, payload) }

  describe '#execute' do
    subject(:execute) { service.execute }

    context 'when alert payload is valid' do
      let(:fingerprint) { '2020-04-27T10:10:22.265949279Z/Alert title/vector(1)' }
      let(:prometheus_status) { 'firing' }
      let(:payload) do
        {
          'status' => prometheus_status,
          'labels' => { 'alertname' => 'GitalyFileServerDown' },
          'annotations' => { 'title' => 'Alert title' },
          'startsAt' => '2020-04-27T10:10:22.265949279Z',
          'endsAt' => '2020-04-27T10:20:22.265949279Z',
          'generatorURL' => 'http://8d467bd4607a:9090/graph?g0.expr=vector%281%29&g0.tab=1'
        }
      end

      context 'with on-call schedule' do
        let_it_be(:schedule) { create(:incident_management_oncall_schedule, project: project) }
        let_it_be(:rotation) { create(:incident_management_oncall_rotation, schedule: schedule) }
        let_it_be(:participant) { create(:incident_management_oncall_participant, :with_developer_access, rotation: rotation) }
        let(:users) { [participant.user] }

        it_behaves_like 'oncall users are correctly notified of firing alert'

        context 'with resolving payload' do
          let(:prometheus_status) { 'resolved' }

          it_behaves_like 'oncall users are correctly notified of recovery alert'
        end
      end
    end
  end
end
