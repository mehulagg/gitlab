# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProductIntelligence::CollectServicePingService do
  include UsageDataHelpers

  describe '#execute' do
    subject(:service_ping_payload) { described_class.new.execute }

    let(:metrics_definitions) { standard_metrics + subscription_metrics + operational_metrics + optional_metrics }
    let(:standard_metrics) do
      [
        metric_attributes('uuid', 'GitLab instance unique identifier', "Standard")
      ]
    end

    let(:subscription_metrics) do
      [
        metric_attributes('license_md5', 'The MD5 hash of license key of the GitLab instance', "Subscription")
      ]
    end

    let(:operational_metrics) do
      [
        metric_attributes('counts.merge_requests', 'Count of the number of merge requests', "Operational"),
        metric_attributes('counts.todos', 'Count of todos created', "Operational")
      ]
    end

    let(:optional_metrics) do
      [
        metric_attributes('counts.boards', 'Count of Boards created', "Optional")
      ]
    end

    before do
      stub_usage_data_connections
      stub_object_store_settings

      metrics_definitions.each do |definition|
        allow_next_instance_of(::Gitlab::Usage::Metric, definition[:key_path]) do |metric|
          allow(metric).to receive(:definition).and_return(definition)
        end
      end
    end

    shared_examples 'includes all appointed metrics' do
      specify do
        aggregate_failures do
          expected_metrics.each do |metric|
            is_expected.to have_usage_metric metric[:key_path]
          end
        end
      end
    end

    shared_examples 'does not include any appointed metric' do
      specify do
        aggregate_failures do
          restricted_metrics.each do |metric|
            is_expected.not_to have_usage_metric metric[:key_path]
          end
        end
      end
    end

    shared_examples 'does not collect any data' do
      it { is_expected.to eq({}) }
    end

    shared_examples 'collects all data' do
      include_examples 'includes all appointed metrics' do
        let(:expected_metrics) do
          standard_metrics + subscription_metrics + operational_metrics + optional_metrics
        end
      end
    end

    context 'GitLab instance does not have a license' do
      # License.current.present? == false

      context 'Instance consented to submit optional product intelligence data' do
        before do
          # Gitlab::CurrentSettings.usage_ping_enabled? == true
          stub_config_setting(usage_ping_enabled: true)
        end

        include_examples 'collects all data'
      end

      context 'Instance does NOT consented to submit optional product intelligence data' do
        before do
          # Gitlab::CurrentSettings.usage_ping_enabled? == false
          stub_config_setting(usage_ping_enabled: false)
        end

        include_examples 'does not collect any data'
      end
    end

    context 'GitLab instance have a license' do
      # License.current.present? == true

      context 'Instance consented to submit optional product intelligence data' do
        before do
          # Gitlab::CurrentSettings.usage_ping_enabled? == true
          stub_config_setting(usage_ping_enabled: true)
        end

        context 'Instance subscribes to free TAM service' do
          before do
            # License.current.usage_ping? == true
            create_current_license(usage_ping_required_metrics_enabled: true)
          end

          include_examples 'collects all data'
        end

        context 'Instance does NOT subscribes to free TAM service' do
          before do
            # License.current.usage_ping? == false
            create_current_license(usage_ping_required_metrics_enabled: false)
          end

          include_examples 'includes all appointed metrics' do
            let(:expected_metrics) { standard_metrics + subscription_metrics + optional_metrics }
          end

          include_examples 'does not include any appointed metric' do
            let(:restricted_metrics) { operational_metrics }
          end
        end
      end

      context 'Instance does NOT consented to submit optional product intelligence data' do
        before do
          # Gitlab::CurrentSettings.usage_ping_enabled? == false
          stub_config_setting(usage_ping_enabled: false)
        end

        context 'Instance subscribes to free TAM service' do
          before do
            # License.current.usage_ping? == true
            create_current_license(usage_ping_required_metrics_enabled: true)
          end

          include_examples 'includes all appointed metrics' do
            let(:expected_metrics) { standard_metrics + subscription_metrics + operational_metrics }
          end

          include_examples 'does not include any appointed metric' do
            let(:restricted_metrics) { optional_metrics }
          end
        end

        context 'Instance does NOT subscribes to free TAM service' do
          before do
            # License.current.usage_ping? == false
            create_current_license(usage_ping_required_metrics_enabled: false)
          end

          include_examples 'does not collect any data'
        end
      end
    end
  end

  def metric_attributes(key_path, description, category)
    {
      key_path: key_path,
      description: description,
      data_category: category
    }
  end
end
