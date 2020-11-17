# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Prometheus::Alerts::NotifyService do
  include PrometheusHelpers

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

  context 'with valid payload' do
    let(:alert_firing) { create(:prometheus_alert, project: project) }
    let(:alert_resolved) { create(:prometheus_alert, project: project) }
    let(:payload_raw) { prometheus_alert_payload(firing: [alert_firing], resolved: [alert_resolved]) }
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
        create(:clusters_applications_prometheus, :installed,
               cluster: prd_cluster, alert_manager_token: token)
        create(:clusters_applications_prometheus, :installed,
               cluster: stg_cluster, alert_manager_token: nil)
      end

      context 'without token' do
        let(:token_input) { nil }

        it_behaves_like 'Alert Notification Service sends notification email'
      end

      context 'with token' do
        it_behaves_like 'Alert Notification Service sends no notifications', http_status: :unauthorized
      end
    end
  end
end
