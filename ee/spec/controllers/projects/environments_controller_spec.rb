# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::EnvironmentsController do
  include KubernetesHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let_it_be(:environment) do
    create(:environment, name: 'production', project: project)
  end

  before do
    project.add_maintainer(user)

    sign_in(user)
  end

  describe 'GET index' do
    context 'when requesting JSON response for folders' do
      before do
        allow_any_instance_of(EE::Environment).to receive(:has_terminals?).and_return(true)
        allow_any_instance_of(EE::Environment).to receive(:rollout_status).and_return(kube_deployment_rollout_status)

        create(:environment, project: project,
                             name: 'staging/review-1',
                             state: :available)

        create(:environment, project: project,
                             name: 'staging/review-2',
                             state: :available)

        create(:environment, project: project,
                             name: 'staging/review-3',
                             state: :stopped)
      end

      let(:environments) { json_response['environments'] }

      context 'when requesting available environments scope' do
        before do
          stub_licensed_features(deploy_board: true)

          get :index, params: environment_params(format: :json, nested: true, scope: :available)
        end

        it 'responds with matching schema' do
          expect(response).to match_response_schema('environments', dir: 'ee')
        end

        it 'responds with a payload describing available environments' do
          expect(environments.count).to eq 2
          expect(environments.first['name']).to eq 'production'
          expect(environments.first['latest']['rollout_status']).to be_present
          expect(environments.second['name']).to eq 'staging'
          expect(environments.second['size']).to eq 2
          expect(environments.second['latest']['name']).to eq 'staging/review-2'
          expect(environments.second['latest']['rollout_status']).to be_present
        end
      end

      context 'when license does not have the GitLab_DeployBoard add-on' do
        before do
          stub_licensed_features(deploy_board: false)

          get :index, params: environment_params(format: :json, nested: true)
        end

        it 'does not return the rollout_status_path attribute' do
          expect(environments.first['latest']['rollout_status']).not_to be_present
          expect(environments.second['latest']['rollout_status']).not_to be_present
        end
      end
    end
  end

  describe '#GET terminal' do
    let(:protected_environment) { create(:protected_environment, name: environment.name, project: project) }

    before do
      allow(License).to receive(:feature_available?).and_call_original
      allow(License).to receive(:feature_available?).with(:protected_environments).and_return(true)
    end

    context 'when environment is protected' do
      context 'when user does not have access to it' do
        before do
          protected_environment

          get :terminal, params: environment_params
        end

        it 'responds with access denied' do
          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'when user has access to it' do
        before do
          protected_environment.deploy_access_levels.create!(user: user)

          get :terminal, params: environment_params
        end

        it 'is successful' do
          expect(response).to have_gitlab_http_status(:ok)
        end
      end
    end

    context 'when environment is not protected' do
      it 'is successful' do
        get :terminal, params: environment_params

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  describe 'POST #cancel_auto_stop' do
    subject { post :cancel_auto_stop, params: params }

    let(:params) { environment_params }

    context 'when environment is set as auto-stop' do
      let(:environment) { create(:environment, :will_auto_stop, name: 'staging', project: project) }

      it_behaves_like 'successful response for #cancel_auto_stop'

      context 'when the environment is protected' do
        before do
          stub_licensed_features(protected_environments: true)
          create(:protected_environment, name: 'staging', project: project)
        end

        it 'shows not found' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  def environment_params(opts = {})
    opts.reverse_merge(namespace_id: project.namespace,
                       project_id: project,
                       id: environment.id)
  end
end
