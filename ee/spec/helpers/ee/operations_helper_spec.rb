# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OperationsHelper, :routing do
  let_it_be(:project) { create(:project, :private) }

  before do
    helper.instance_variable_set(:@project, project)
  end

  describe '#status_page_settings_data' do
    let_it_be(:user) { create(:user) }
    let_it_be(:status_page_setting) { project.build_status_page_setting }

    subject { helper.status_page_settings_data }

    before do
      allow(helper).to receive(:status_page_setting) { status_page_setting }
      allow(helper).to receive(:current_user) { user }
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
    subject { helper.alerts_settings_data }

    describe 'Opsgenie MVC attributes' do
      let_it_be(:alerts_service) do
        create(:alerts_service,
          project: project,
          opsgenie_mvc_enabled: false,
          opsgenie_mvc_target_url: 'https://appname.app.opsgenie.com/alert/list'
        )
      end

      let_it_be(:prometheus_service) { build_stubbed(:prometheus_service) }

      before do
        allow(helper).to receive(:alerts_service).and_return(alerts_service)
        allow(helper).to receive(:prometheus_service).and_return(prometheus_service)
        allow(alerts_service).to receive(:opsgenie_mvc_available?).and_return(opsgenie_available)
      end

      context 'when available' do
        let(:opsgenie_available) { true }

        it do
          is_expected.to include(
            'opsgenie_mvc_available' => 'true',
            'opsgenie_mvc_form_path' => project_service_path(project, alerts_service),
            'opsgenie_mvc_enabled' => 'false',
            'opsgenie_mvc_target_url' => 'https://appname.app.opsgenie.com/alert/list'
          )
        end
      end

      context 'when not available' do
        let(:opsgenie_keys) do
          %w[opsgenie_mvc_available opsgenie_mvc_enabled opsgenie_mvc_form_path opsgenie_mvc_target_url]
        end

        let(:opsgenie_available) { false }

        it { is_expected.not_to include(opsgenie_keys) }
      end
    end
  end
end
