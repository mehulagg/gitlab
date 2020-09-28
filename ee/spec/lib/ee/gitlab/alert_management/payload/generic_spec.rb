# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::Payload::Generic do
  let_it_be(:project) { build_stubbed(:project) }
  let(:raw_payload) { {} }
  let(:parsed_payload) { described_class.new(project: project, payload: raw_payload) }

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
