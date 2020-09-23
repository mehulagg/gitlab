# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Alerting::NotificationPayloadParser do
  let(:project) { build_stubbed(:project) }

  describe '.call' do
    subject(:parsed) { described_class.call(payload, project) }

    let(:payload) do
      {
        'title' => 'alert title',
        'start_time' => Time.current,
        'description' => 'Description',
        'monitoring_tool' => 'Monitoring tool name',
        'service' => 'Service',
        'hosts' => ['gitlab.com'],
        'severity' => 'low'
      }
    end

    describe 'fingerprint' do
      subject(:fingerprint) { parsed.dig('annotations', 'fingerprint') }

      context 'license feature enabled' do
        before do
          stub_licensed_features(generic_alert_fingerprinting: true)
        end

        it 'generates the fingerprint from the payload' do
          fingerprint_payload = payload.excluding('start_time', 'hosts')
          expected_fingerprint = Gitlab::AlertManagement::Fingerprint.generate(fingerprint_payload)

          expect(fingerprint).to eq(expected_fingerprint)
        end

        context 'payload has no values' do
          let(:payload) do
            {
              'start_time' => Time.current,
              'hosts' => ['gitlab.com'],
              'title' => ' '
            }
          end

          it { is_expected.to eq(nil) }
        end
      end

      context 'license feature not enabled' do
        it { is_expected.to eq(nil) }
      end
    end
  end
end
