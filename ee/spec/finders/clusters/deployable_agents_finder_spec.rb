# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::DeployableAgentsFinder do
  describe '#execute' do
    let_it_be(:agent) { create(:cluster_agent) }

    let(:project) { agent.project }

    subject { described_class.new(project).execute }

    before do
      stub_licensed_features(cluster_agents: feature_available)
    end

    context 'feature is available' do
      let(:feature_available) { true }

      it { is_expected.to contain_exactly(agent) }
    end

    context 'feature is not available' do
      let(:feature_available) { false }

      it { is_expected.to be_empty }
    end
  end
end
