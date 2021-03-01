# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::ClusterAgentsController do
  let_it_be(:cluster_agent) { create(:cluster_agent) }

  let(:project) { cluster_agent.project }
  let(:params) { { namespace_id: project.namespace, project_id: project, name: cluster_agent.name } }

  describe 'GET show' do
    subject { get :show, params: params }

    context 'when user is unauthorized' do
      let_it_be(:user) { create(:user) }

      before do
        project.add_developer(user)
        sign_in(user)
        subject
      end

      it 'shows 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is authorized' do
      let(:user) { project.creator }

      context 'without premium plan' do
        before do
          sign_in(user)
          subject
        end

        it 'shows 404' do
          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'with premium plan' do
        before do
          stub_licensed_features(cluster_agents: true)
          sign_in(user)
          subject
        end

        it 'renders content' do
          expect(response).to be_successful
        end
      end
    end
  end
end
