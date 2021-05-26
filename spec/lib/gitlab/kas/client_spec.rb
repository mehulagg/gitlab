# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Kas::Client do
  let_it_be(:project) { create(:project) }

  before do
    allow(Gitlab::Kas).to receive(:internal_url).and_return('grpc://example.kas.internal')
  end

  describe '#initialize' do
    context 'kas is not enabled' do
      before do
        allow(Gitlab::Kas).to receive(:enabled?).and_return(false)
      end

      it 'raises a configuration error' do
        expect { described_class.new }.to raise_error(described_class::ConfigurationError, 'GitLab KAS is not enabled')
      end
    end
  end

  describe '#get_connected_agents' do
    let(:stub) { instance_double(Gitlab::Agent::AgentTracker::Rpc::AgentTracker::Stub) }
    let(:token) { instance_double(JSONWebToken::HMACToken, encoded: 'test-token') }
    let(:request) { instance_double(Gitlab::Agent::AgentTracker::Rpc::GetConnectedAgentsRequest) }
    let(:response) { instance_double(Gitlab::Agent::AgentTracker::Rpc::GetConnectedAgentsResponse) }

    subject { described_class.new.get_connected_agents(project_id: project.id) }

    before do
      expect(Gitlab::Agent::AgentTracker::Rpc::AgentTracker::Stub).to receive(:new)
        .with('example.kas.internal', :this_channel_is_insecure, timeout: described_class::TIMEOUT)
        .and_return(stub)

      expect(JSONWebToken::HMACToken).to receive(:new)
        .with(File.read(Gitlab::Kas.secret_path))
        .and_return(token)

      expect(Gitlab::Agent::AgentTracker::Rpc::GetConnectedAgentsRequest).to receive(:new)
        .with(project_id: project.id)
        .and_return(request)

      expect(stub).to receive(:get_connected_agents)
        .with(request, metadata: { 'authorization' => 'bearer test-token' })
        .and_return(response)
    end

    it { expect(subject).to eq(response) }
  end
end
