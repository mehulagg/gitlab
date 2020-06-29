# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::ProcessPrometheusAlertService do
  let_it_be(:project) { create(:project) }

  before do
    allow(ProjectServiceWorker).to receive(:perform_async)
  end

  describe '#execute' do
    subject(:execute) { described_class.new(project, nil, payload).execute }

    context 'when alert payload is valid' do
      let(:parsed_alert) { Gitlab::Alerting::Alert.new(project: project, payload: payload) }
      let(:payload) do
        {
          'status' => status,
          'labels' => {
            'alertname' => 'GitalyFileServerDown',
            'channel' => 'gitaly',
            'pager' => 'pagerduty',
            'severity' => 's1'
          },
          'annotations' => {
            'description' => 'Alert description',
            'runbook' => 'troubleshooting/gitaly-down.md',
            'title' => 'Alert title'
          },
          'startsAt' => '2020-04-27T10:10:22.265949279Z',
          'endsAt' => '2020-04-27T10:20:22.265949279Z',
          'generatorURL' => 'http://8d467bd4607a:9090/graph?g0.expr=vector%281%29&g0.tab=1',
          'fingerprint' => 'b6ac4d42057c43c1'
        }
      end

      let(:status) { 'firing' }

      context 'when Prometheus alert status is firing' do
        context 'when alert with the same fingerprint already exists' do
          let!(:alert) { create(:alert_management_alert, :resolved, project: project, fingerprint: parsed_alert.gitlab_fingerprint) }

          it 'increases alert events count' do
            expect { execute }.to change { alert.reload.events }.by(1)
          end

          context 'when status can be changed' do
            it 'changes status to triggered' do
              expect { execute }.to change { alert.reload.triggered? }.to(true)
            end
          end

          it 'does not executes the alert service hooks' do
            expect(alert).not_to receive(:execute_services)

            subject
          end

          context 'when status change did not succeed' do
            before do
              allow(AlertManagement::Alert).to receive(:for_fingerprint).and_return([alert])
              allow(alert).to receive(:trigger).and_return(false)
            end

            it 'writes a warning to the log' do
              expect(Gitlab::AppLogger).to receive(:warn).with(
                message: 'Unable to update AlertManagement::Alert status to triggered',
                project_id: project.id,
                alert_id: alert.id
              )

              execute
            end
          end

          it { is_expected.to be_success }
        end

        context 'when alert does not exist' do
          context 'when alert can be created' do
            it 'creates a new alert' do
              expect { execute }.to change { AlertManagement::Alert.where(project: project).count }.by(1)
            end

            it 'executes the alert service hooks' do
              slack_service = create(:service, type: 'SlackService', project: project, alert_events: true, active: true)

              subject

              expect(ProjectServiceWorker).to have_received(:perform_async).with(slack_service.id, an_instance_of(Hash))
            end
          end

          context 'when alert cannot be created' do
            let(:errors) { double(messages: { hosts: ['hosts array is over 255 chars'] })}
            let(:am_alert) { instance_double(AlertManagement::Alert, save: false, errors: errors) }

            before do
              allow(AlertManagement::Alert).to receive(:new).and_return(am_alert)
            end

            it 'writes a warning to the log' do
              expect(Gitlab::AppLogger).to receive(:warn).with(
                message: 'Unable to create AlertManagement::Alert',
                project_id: project.id,
                alert_errors: { hosts: ['hosts array is over 255 chars'] }
              )

              execute
            end
          end

          it { is_expected.to be_success }
        end
      end

      context 'when Prometheus alert status is resolved' do
        let(:status) { 'resolved' }
        let!(:alert) { create(:alert_management_alert, project: project, fingerprint: parsed_alert.gitlab_fingerprint) }

        context 'when status can be changed' do
          it 'resolves an existing alert' do
            expect { execute }.to change { alert.reload.resolved? }.to(true)
          end
        end

        context 'when status change did not succeed' do
          before do
            allow(AlertManagement::Alert).to receive(:for_fingerprint).and_return([alert])
            allow(alert).to receive(:resolve).and_return(false)
          end

          it 'writes a warning to the log' do
            expect(Gitlab::AppLogger).to receive(:warn).with(
              message: 'Unable to update AlertManagement::Alert status to resolved',
              project_id: project.id,
              alert_id: alert.id
            )

            execute
          end
        end

        it { is_expected.to be_success }
      end

      context 'environment given' do
        let(:project) { create(:project, :repository) }
        let(:environment) { create(:environment, project: project) }

        it 'sets the environment' do
          payload['labels']['gitlab_environment_name'] = environment.name
          execute

          alert = project.alert_management_alerts.last

          expect(alert.environment).to eq(environment)
        end
      end

      context 'prometheus alert given' do
        let(:prometheus_alert) { create(:prometheus_alert, project: project) }

        it 'sets the prometheus alert and environment' do
          payload['labels']['gitlab_alert_id'] = prometheus_alert.prometheus_metric_id
          execute

          alert = project.alert_management_alerts.last

          expect(alert.prometheus_alert).to eq(prometheus_alert)
          expect(alert.environment).to eq(prometheus_alert.environment)
        end
      end
    end

    context 'when alert payload is invalid' do
      let(:payload) { {} }

      it 'responds with bad_request' do
        expect(execute).to be_error
        expect(execute.http_status).to eq(:bad_request)
      end
    end
  end
end
