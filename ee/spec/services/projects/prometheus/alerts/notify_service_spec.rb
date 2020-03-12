# frozen_string_literal: true

require 'spec_helper'

describe Projects::Prometheus::Alerts::NotifyService do
  let_it_be(:project, reload: true) { create(:project) }

  let(:service) { described_class.new(project, nil, payload) }
  let(:token_input) { 'token' }

  let!(:setting) do
    create(:project_incident_management_setting, project: project, send_email: true, create_issue: true)
  end

  let(:subject) { service.execute(token_input) }

  before do
    # We use `let_it_be(:project)` so we make sure to clear caches
    project.clear_memoization(:licensed_feature_available)
  end

  shared_examples 'sends notification email' do
    let(:notification_service) { spy }

    it 'sends a notification for firing alerts only' do
      expect(NotificationService)
        .to receive(:new)
        .and_return(notification_service)

      expect(notification_service)
        .to receive_message_chain(:async, :prometheus_alerts_fired)

      expect(subject).to eq(true)
    end
  end

  shared_examples 'processes incident issues' do |amount|
    let(:create_incident_service) { spy }

    it 'processes issues' do
      expect(IncidentManagement::ProcessPrometheusAlertWorker)
        .to receive(:perform_async)
        .with(project.id, kind_of(Hash))
        .exactly(amount).times

      Sidekiq::Testing.inline! do
        expect(subject).to eq(true)
      end
    end
  end

  shared_examples 'does not process incident issues' do
    it 'does not process issues' do
      expect(IncidentManagement::ProcessPrometheusAlertWorker)
        .not_to receive(:perform_async)

      expect(subject).to eq(true)
    end
  end

  shared_examples 'persists events' do
    let(:create_events_service) { spy }

    it 'persists events' do
      expect(Projects::Prometheus::Alerts::CreateEventsService)
        .to receive(:new)
        .and_return(create_events_service)

      expect(create_events_service)
        .to receive(:execute)

      expect(subject).to eq(true)
    end
  end

  shared_examples 'notifies alerts' do
    it_behaves_like 'sends notification email'
    it_behaves_like 'persists events'
  end

  shared_examples 'no notifications' do
    let(:notification_service) { spy }
    let(:create_events_service) { spy }

    it 'does not notify' do
      expect(notification_service).not_to receive(:async)
      expect(create_events_service).not_to receive(:execute)

      expect(subject).to eq(false)
    end
  end

  context 'with valid payload' do
    let(:alert_firing) { create(:prometheus_alert, project: project) }
    let(:alert_resolved) { create(:prometheus_alert, project: project) }
    let(:payload_raw) { payload_for(firing: [alert_firing], resolved: [alert_resolved]) }
    let(:payload) { ActionController::Parameters.new(payload_raw).permit! }
    let(:payload_alert_firing) { payload_raw['alerts'].first }
    let(:token) { 'token' }

    context 'with environment specific clusters' do
      let(:prd_cluster) do
        create(:cluster, :provided_by_user, projects: [project], enabled: true, environment_scope: '*')
      end
      let(:stg_cluster) do
        create(:cluster, :provided_by_user, projects: [project], enabled: true, environment_scope: 'stg/*')
      end

      let(:stg_environment) do
        create(:environment, project: project, name: 'stg/1')
      end

      let(:alert_firing) do
        create(:prometheus_alert, project: project, environment: stg_environment)
      end

      before do
        stub_licensed_features(multiple_clusters: true)

        create(:clusters_applications_prometheus, :installed,
               cluster: prd_cluster, alert_manager_token: token)
        create(:clusters_applications_prometheus, :installed,
               cluster: stg_cluster, alert_manager_token: nil)
      end

      context 'without token' do
        let(:token_input) { nil }

        it_behaves_like 'notifies alerts'
      end

      context 'with token' do
        it_behaves_like 'no notifications'
      end
    end
  end

  private

  def payload_for(firing: [], resolved: [])
    status = firing.any? ? 'firing' : 'resolved'
    alerts = firing + resolved
    alert_name = alerts.first.title
    prometheus_metric_id = alerts.first.prometheus_metric_id.to_s

    alerts_map = \
      firing.map { |alert| map_alert_payload('firing', alert) } +
      resolved.map { |alert| map_alert_payload('resolved', alert) }

    # See https://prometheus.io/docs/alerting/configuration/#%3Cwebhook_config%3E
    {
      'version' => '4',
      'receiver' => 'gitlab',
      'status' => status,
      'alerts' => alerts_map,
      'groupLabels' => {
        'alertname' => alert_name
      },
      'commonLabels' => {
        'alertname' => alert_name,
        'gitlab' => 'hook',
        'gitlab_alert_id' => prometheus_metric_id
      },
      'commonAnnotations' => {},
      'externalURL' => '',
      'groupKey' => "{}:{alertname=\'#{alert_name}\'}"
    }
  end

  def map_alert_payload(status, alert)
    {
      'status' => status,
      'labels' => {
        'alertname' => alert.title,
        'gitlab' => 'hook',
        'gitlab_alert_id' => alert.prometheus_metric_id.to_s
      },
      'annotations' => {},
      'startsAt' => '2018-09-24T08:57:31.095725221Z',
      'endsAt' => '0001-01-01T00:00:00Z',
      'generatorURL' => 'http://prometheus-prometheus-server-URL'
    }
  end
end
