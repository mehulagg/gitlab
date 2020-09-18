# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ClusterAgents', :js do
  let_it_be(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    project.add_maintainer(user)
    gitlab_sign_in(user)
  end

  context 'non-premium user' do
    context 'when user visits cluster index page' do
      before do
        visit project_clusters_path(project)
      end

      it 'does not display agent information', :aggregate_failures do
        expect(page).to have_content('Clusters connected with a certificate')
        expect(page).not_to have_content('GitLab Agent managed clusters')
      end
    end
  end

  context 'premium user' do
    before do
      stub_licensed_features(cluster_agents: true)
    end

    context 'when user does not have any agents and visits the cluster index page' do
      before do
        visit project_clusters_path(project)
      end

      it 'sees empty state', :aggregate_failures do
        expect(page).to have_link('Integrate with the GitLab Agent')
        expect(page).to have_selector('.empty-state')
      end
    end

    context 'when user has an agent and visits the cluster index page' do
      let_it_be(:cluster_agent) { create(:cluster_agent) }
      let(:project) { cluster_agent.project }

      before do
        visit project_clusters_path(project)
      end

      it 'user sees a table with agent', :aggregate_failures do
        expect(page).to have_content(cluster_agent.name)
        expect(page).to have_selector('[data-qa-selector="cluster_agent_list_table"] tbody tr', count: 1)
      end
    end
  end
end
