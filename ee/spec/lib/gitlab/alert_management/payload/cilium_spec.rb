# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::Payload::Cilium do
  let_it_be(:project) { build_stubbed(:project) }

  let(:raw_payload) { build(:network_alert_payload) }

  let(:parsed_payload) do
    described_class.new(project: project, payload: Gitlab::Json.parse(raw_payload.to_json))
  end

  it 'parses cilium specific fields' do
    expect(parsed_payload.title).to eq('Cilium Alert')
    expect(parsed_payload.description).to eq('POLICY_DENIED')
    expect(parsed_payload.gitlab_fingerprint).to eq('23907c66f431ae66aad738553ccbd03e26f6838f')
  end

  context 'when title is not provided' do
    before do
      raw_payload[:ciliumNetworkPolicy][:metadata][:name] = nil
    end

    it 'uses a fallback title' do
      expect(parsed_payload.title).to eq('New: Alert')
    end
  end
end
