# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Clusters::AgentsFinder do
  describe '#execute' do
    let(:project) { create(:project) }
    let(:user) { create(:user, maintainer_projects: [project]) }
    let(:feature_available) { true }

    let!(:matching_agent) { create(:cluster_agent, project: project) }
    let!(:wrong_project) { create(:cluster_agent) }

    subject { described_class.new(project, user).execute }

    before do
      stub_licensed_features(cluster_agents: feature_available)
    end

    it { is_expected.to contain_exactly(matching_agent) }

    context 'feature is not available' do
      let(:feature_available) { false }

      it { is_expected.to be_empty }
    end

    context 'user does not have permission' do
      let(:user) { create(:user, developer_projects: [project]) }

      it { is_expected.to be_empty }
    end

    context 'filtering by name' do
      let(:params) { Hash(name: name_param) }

      subject { described_class.new(project, user, params: params).execute }

      context 'name does not match' do
        let(:name_param) { 'other-name' }

        it { is_expected.to be_empty }
      end

      context 'name does match' do
        let(:name_param) { matching_agent.name }

        it { is_expected.to contain_exactly(matching_agent) }
      end
    end
  end
end
