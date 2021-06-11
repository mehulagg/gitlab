# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OperationsHelper, :routing do
  let_it_be_with_refind(:project) { create(:project, :private) }
  let_it_be(:user) { create(:user) }

  before do
    helper.instance_variable_set(:@project, project)
    allow(helper).to receive(:current_user) { user }
  end

  describe '#status_page_settings_data' do
    let_it_be(:status_page_setting) { project.build_status_page_setting }

    subject { helper.status_page_settings_data }

    before do
      allow(helper).to receive(:status_page_setting) { status_page_setting }
      allow(helper)
        .to receive(:can?).with(user, :admin_operations, project) { true }
    end

    context 'setting does not exist' do
      it 'returns the correct values' do
        expect(subject).to eq(
          'operations-settings-endpoint' => project_settings_operations_path(project),
          'enabled' => 'false',
          'url' => nil,
          'aws-access-key' => nil,
          'aws-secret-key' => nil,
          'region' => nil,
          'bucket-name' => nil
        )
      end

      context 'user does not have permission' do
        before do
          allow(helper)
            .to receive(:can?).with(user, :admin_operations, project) { false }
        end

        it 'returns the correct values' do
          expect(subject).to eq(
            'operations-settings-endpoint' => project_settings_operations_path(project),
            'enabled' => 'false',
            'url' => nil,
            'aws-access-key' => nil,
            'aws-secret-key' => nil,
            'region' => nil,
            'bucket-name' => nil
          )
        end
      end
    end

    context 'setting exists' do
      let(:status_page_setting) { create(:status_page_setting, project: project) }

      it 'returns the correct values' do
        expect(subject).to eq(
          'operations-settings-endpoint' => project_settings_operations_path(project),
          'enabled' => status_page_setting.enabled.to_s,
          'url' => status_page_setting.status_page_url,
          'aws-access-key' => status_page_setting.aws_access_key,
          'aws-secret-key' => status_page_setting.masked_aws_secret_key,
          'region' => status_page_setting.aws_region,
          'bucket-name' => status_page_setting.aws_s3_bucket_name
        )
      end
    end
  end

  describe '#alerts_settings_data' do
    subject(:alerts_settings_data) { helper.alerts_settings_data }

    describe 'Multiple Integrations Support' do
      before do
        stub_licensed_features(multiple_alert_http_integrations: multi_integrations)
      end

      context 'when available' do
        let(:multi_integrations) { true }

        it { is_expected.to include('multi_integrations' => 'true') }

        it 'has the correct list of fields', :aggregate_failures do
          fields = Gitlab::Json.parse(alerts_settings_data['alert_fields'])

          expect(fields.count).to eq(10)
          expect(fields.first.keys).to eq(%w[name label types])
          expect(fields.map { |f| f['name'] }).to match_array(
            %w[title description start_time end_time service monitoring_tool hosts severity fingerprint gitlab_environment_name]
          )
        end
      end

      context 'when not available' do
        let(:multi_integrations) { false }

        it { is_expected.to include('multi_integrations' => 'false') }
        it { is_expected.not_to have_key('alert_fields') }
      end
    end
  end

  describe '#operations_settings_data' do
    let_it_be(:operations_settings) do
      create(
        :project_incident_management_setting,
        project: project,
        pagerduty_active: true
      )
    end

    subject { helper.operations_settings_data }

    it 'returns the correct set of data' do
      is_expected.to eq(
        operations_settings_endpoint: project_settings_operations_path(project),
        pagerduty_active: 'true',
        pagerduty_token: operations_settings.pagerduty_token,
        pagerduty_webhook_url: project_incidents_integrations_pagerduty_url(project, token: operations_settings.pagerduty_token),
        pagerduty_reset_key_path: reset_pagerduty_token_project_settings_operations_path(project),
        sla_feature_available: 'false',
        sla_active: operations_settings.sla_timer.to_s,
        sla_minutes: operations_settings.sla_timer_minutes
      )
    end

    context 'incident_sla feature enabled' do
      before do
        stub_licensed_features(incident_sla: true)
      end

      it 'returns the feature as enabled' do
        expect(subject[:sla_feature_available]).to eq('true')
      end
    end
  end
end
