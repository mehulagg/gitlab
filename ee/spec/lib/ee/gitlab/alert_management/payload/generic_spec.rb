# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::Payload::Generic do
  let_it_be(:project) { create(:project) }
  let_it_be(:raw_payload) { {} }
  let(:parsed_payload) { described_class.new(project: project, payload: raw_payload) }

  shared_examples 'parsing alert payload fields with default paths' do
    describe '#title' do
      subject { parsed_payload.title }

      it { is_expected.to eq('default title') }
    end
  end

  describe 'attributes' do
    let_it_be(:raw_payload) do
      {
        'title' => 'default title',
        'alert' => {
          'name' => 'mapped title'
        }
      }
    end

    context 'with multiple HTTP integrations feature available' do
      before do
        stub_licensed_features(multiple_alert_http_integrations: true)
      end

      context 'with multiple_http_integrations_custom_mapping feature flag enabled' do
        let_it_be(:attribute_mapping) do
          {
            title: { path: %w(alert name), type: 'string', label: 'Name' }
          }
        end

        before do
          stub_feature_flags(multiple_http_integrations_custom_mapping: project)
        end

        context 'with defined custom mapping' do
          let_it_be(:integration) do
            create(:alert_management_http_integration, project: project, payload_attribute_mapping: attribute_mapping)
          end

          context '#title' do
            subject { parsed_payload.title }

            it { is_expected.to eq('mapped title') }
          end
        end

        context 'with inactive HTTP integration' do
          let_it_be(:integration) do
            create(:alert_management_http_integration, :inactive, project: project, payload_attribute_mapping: attribute_mapping)
          end

          it_behaves_like 'parsing alert payload fields with default paths'
        end

        context 'with blank custom mapping' do
          let_it_be(:integration) { create(:alert_management_http_integration, project: project) }

          it_behaves_like 'parsing alert payload fields with default paths'
        end
      end

      context 'with multiple_http_integrations_custom_mapping feature flag disabled' do
        before do
          stub_feature_flags(multiple_http_integrations_custom_mapping: false)
        end

        it_behaves_like 'parsing alert payload fields with default paths'
      end
    end

    context 'with multiple HTTP integrations feature unavailable' do
      before do
        stub_licensed_features(multiple_alert_http_integrations: false)
      end

      it_behaves_like 'parsing alert payload fields with default paths'
    end
  end

  describe '#gitlab_fingerprint' do
    subject { parsed_payload.gitlab_fingerprint }

    context 'with fingerprint defined in payload' do
      let(:expected_fingerprint) { Digest::SHA1.hexdigest(plain_fingerprint) }
      let(:plain_fingerprint) { 'fingerprint' }
      let(:raw_payload) { { 'fingerprint' => plain_fingerprint } }

      it { is_expected.to eq(expected_fingerprint) }
    end

    context 'license feature enabled' do
      let(:expected_fingerprint) { Gitlab::AlertManagement::Fingerprint.generate(plain_fingerprint) }
      let(:plain_fingerprint) { raw_payload.except('hosts', 'start_time') }
      let(:raw_payload) do
        {
          'keep-this' => 'attribute',
          'hosts' => 'remove me',
          'start_time' => 'remove me'
        }
      end

      before do
        stub_licensed_features(generic_alert_fingerprinting: true)
      end

      it { is_expected.to eq(expected_fingerprint) }

      context 'payload has no values' do
        let(:raw_payload) do
          {
            'start_time' => '2020-09-17 12:49:54 -0400',
            'hosts' => ['gitlab.com'],
            'end_time' => '2020-09-17 12:59:54 -0400',
            'title' => ' '
          }
        end

        it { is_expected.to be_nil }
      end
    end

    context 'license feature not enabled' do
      it { is_expected.to be_nil }
    end
  end
end
