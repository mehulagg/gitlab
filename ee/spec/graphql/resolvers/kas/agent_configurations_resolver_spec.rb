# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Kas::AgentConfigurationsResolver do
  include GraphqlHelpers

  it { expect(described_class.type).to eq(Types::Kas::AgentConfigurationType) }
  it { expect(described_class.null).to be_truthy }
  it { expect(described_class.field_options).to include(calls_gitaly: true) }

  describe '#resolve' do
    let_it_be(:project) { create(:project) }

    let(:user) { create(:user, developer_projects: [project]) }
    let(:ctx) { Hash(current_user: user) }
    let(:feature_available) { true }

    let(:agent1) { double }
    let(:agent2) { double }
    let(:kas_client) { instance_double(Gitlab::Kas::Client, list_agent_config_files: [agent1, agent2]) }

    subject { resolve(described_class, obj: project, ctx: ctx) }

    before do
      stub_licensed_features(cluster_agents: feature_available)

      allow(Gitlab::Kas::Client).to receive(:new).and_return(kas_client)
    end

    it 'returns tokens associated with the agent, ordered by last_used_at' do
      expect(subject).to contain_exactly(agent1, agent2)
    end

    context 'feature is not available' do
      let(:feature_available) { false }

      it { is_expected.to be_empty }
    end

    context 'user does not have permission' do
      let(:user) { create(:user) }

      it { is_expected.to be_empty }
    end
  end
end
