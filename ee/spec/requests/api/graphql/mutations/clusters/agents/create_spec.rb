# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create a new cluster agent' do
  include GraphqlHelpers

  let(:project) { create(:project, :public, :repository) }
  let(:project_name) { 'agent-test' }
  let(:current_user) { create(:user) }

  let(:mutation) do
    graphql_mutation(
      :create_cluster_agent,
      { project_path: project.full_path, name: project_name }
    )
  end

  def mutation_response
    graphql_mutation_response(:create_cluster_agent)
  end

  context 'without project permissions' do
    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create cluster agent' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Clusters::Agent, :count)
    end
  end

  context 'without premium plan' do
    before do
      allow(License).to receive(:current).and_return(create(:license, plan: ::License::STARTER_PLAN))
      project.add_maintainer(current_user)
    end

    it 'does not create cluster agent and returns error message' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Clusters::Agent, :count)
      expect(mutation_response['errors']).to eq(['This feature is only available for premium plans'])
    end
  end

  context 'with premium plan and user permissions' do
    before do
      allow(License).to receive(:current).and_return(create(:license, plan: ::License::PREMIUM_PLAN))
      project.add_maintainer(current_user)
    end

    it 'creates a new cluster agent' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.to change { Clusters::Agent.count }.by(1)
      expect(mutation_response.dig('clusterAgent', 'name')).to eq(project_name)
      expect(mutation_response['errors']).to eq([])
    end
  end
end
