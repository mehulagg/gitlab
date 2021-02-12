# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::AlertManagement::Payload::Cilium do
  let_it_be(:project) { build_stubbed(:project) }
  let(:raw_payload) { build(:network_alert_payload).to_json }

  let(:parsed_payload) do
    described_class.new(project: project, payload: Gitlab::Json.parse(raw_payload))
  end

  it 'parses cilium specific fields' do
    expect(parsed_payload.title).to eq('Cilium Alert')
    expect(parsed_payload.description).to eq('POLICY_DENIED')
    expect(parsed_payload.gitlab_fingerprint).to eq('b2ad2a791756abe01692270c6a846129a09891b3')
  end
end
