# frozen_string_literal: true

require 'spec_helper'

describe OperationsController do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }

  shared_examples 'unlicensed' do |http_method, action|
    before do
      stub_licensed_features(operations_dashboard: false)
    end

    it 'renders 404' do
      public_send(http_method, action)

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  before do
    stub_licensed_features(operations_dashboard: true)
    sign_in(user)
  end

  describe 'GET #index' do
    it_behaves_like 'unlicensed', :get, :index

    it 'renders index with 200 status code' do
      get :index

      expect(response).to have_gitlab_http_status(200)
      expect(response).to render_template(:index)
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :index

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #environments' do
    it_behaves_like 'unlicensed', :get, :environments

    it 'renders the view' do
      get :environments

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:environments)
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :environments

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #list' do
    let(:now) { Time.now.change(usec: 0) }
    let(:project) { create(:project, :repository) }
    let(:commit) { project.commit }
    let!(:environment) { create(:environment, name: 'production', project: project) }
    let!(:deployment) { create(:deployment, :success, environment: environment, sha: commit.id, created_at: now) }

    it_behaves_like 'unlicensed', :get, :list

    shared_examples 'empty project list' do
      it 'returns an empty list' do
        get :list

        expect(response).to have_gitlab_http_status(200)
        expect(json_response).to match_schema('dashboard/operations/list', dir: 'ee')
        expect(json_response['projects']).to eq([])
      end
    end

    context 'with added projects' do
      let(:alert1) { create(:prometheus_alert, project: project, environment: environment) }
      let(:alert2) { create(:prometheus_alert, project: project, environment: environment) }

      let!(:alert_events) do
        [
          create(:prometheus_alert_event, prometheus_alert: alert1),
          create(:prometheus_alert_event, prometheus_alert: alert2),
          create(:prometheus_alert_event, prometheus_alert: alert1),
          create(:prometheus_alert_event, :resolved, prometheus_alert: alert2)
        ]
      end

      let(:firing_alert_events) { alert_events.select(&:firing?) }
      let(:last_firing_alert) { firing_alert_events.last.prometheus_alert }

      let(:alert_path) do
        metrics_project_environment_path(project, environment)
      end

      let(:alert_json_path) do
        project_prometheus_alert_path(project, last_firing_alert.prometheus_metric_id,
                                      environment_id: environment, format: :json)
      end

      let(:expected_project) { json_response['projects'].first }

      before do
        user.update!(ops_dashboard_projects: [project])
        project.add_developer(user)
      end

      it 'returns a list of added projects' do
        get :list

        expect(response).to have_gitlab_http_status(200)
        expect(response).to match_response_schema('dashboard/operations/list', dir: 'ee')

        expect(json_response['projects'].size).to eq(1)

        expect(expected_project['id']).to eq(project.id)
        expect(expected_project['remove_path'])
          .to eq(remove_operations_project_path(project_id: project.id))
        expect(expected_project['last_deployment']['id']).to eq(deployment.id)
        expect(expected_project['alert_count']).to eq(firing_alert_events.size)
        expect(expected_project['alert_path']).to eq(alert_path)
        expect(expected_project['last_alert']['id']).to eq(last_firing_alert.id)
      end

      context 'without sufficient access level' do
        before do
          project.add_reporter(user)
        end

        it_behaves_like 'empty project list'
      end
    end

    context 'without projects' do
      it_behaves_like 'empty project list'
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :list

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #environment_list' do
    it_behaves_like 'unlicensed', :get, :environments_list

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        get :environments_list

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with an authenticated user without sufficient access_level' do
      it 'returns an empty project list' do
        project = create(:project)
        project.add_reporter(user)
        user.update!(ops_dashboard_projects: [project])

        get :environments_list

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['projects']).to eq([])
      end
    end

    context 'with an authenticated developer' do
      it 'returns an empty project list' do
        get :environments_list

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['projects']).to eq([])
      end

      it 'sets the polling interval header' do
        get :environments_list

        expect(response).to have_gitlab_http_status(:ok)
        expect(response.headers[Gitlab::PollingInterval::HEADER_NAME]).to eq('120000')
      end

      it "returns an empty project list when the project is not in the developer's dashboard" do
        project = create(:project)
        project.add_developer(user)
        user.update!(ops_dashboard_projects: [])

        get :environments_list

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response['projects']).to eq([])
      end

      it 'returns one project and one environment when the developer has added that project to the dashboard' do
        project = create(:project, :with_avatar)
        environment = create(:environment, project: project)
        create(:deployment, project: project, environment: environment, user: user, status: :success)
        project.add_developer(user)
        user.update!(ops_dashboard_projects: [project])

        get :environments_list

        project_json = json_response['projects'].first
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('dashboard/operations/environments_list', dir: 'ee')
        expect(project_json['id']).to eq(project.id)
        expect(project_json['name']).to eq(project.name)
        expect(project_json['namespace']['id']).to eq(project.namespace.id)
        expect(project_json['namespace']['name']).to eq(project.namespace.name)
        expect(project_json['environments'].first['size']).to eq(1)
        expect(project_json['environments'].first['within_folder']).to eq(false)
        expect(project_json['environments'].first['environment_path']).to eq(project_environment_path(project, environment))
      end

      it 'groups like environments together in a folder' do
        project = create(:project, :with_avatar)
        create(:environment, project: project, name: 'review/test-feature')
        environment = create(:environment, project: project, name: 'review/another-feature')
        create(:deployment, project: project, environment: environment, user: user, status: :success)
        project.add_developer(user)
        user.update!(ops_dashboard_projects: [project])

        get :environments_list

        project_json = json_response['projects'].first
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('dashboard/operations/environments_list', dir: 'ee')
        expect(project_json['environments'].count).to eq(1)
        expect(project_json['environments'].first['size']).to eq(2)
        expect(project_json['environments'].first['within_folder']).to eq(true)
        expect(project_json['environments'].first['id']).to eq(environment.id)
      end

      it 'returns true for within_folder when a folder contains only a single environment' do
        project = create(:project, :with_avatar)
        environment = create(:environment, project: project, name: 'review/test-feature')
        create(:deployment, project: project, environment: environment, user: user, status: :success)
        project.add_developer(user)
        user.update!(ops_dashboard_projects: [project])

        get :environments_list

        project_json = json_response['projects'].first
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('dashboard/operations/environments_list', dir: 'ee')
        expect(project_json['environments'].count).to eq(1)
        expect(project_json['environments'].first['size']).to eq(1)
        expect(project_json['environments'].first['within_folder']).to eq(true)
      end

      it 'counts only available environments' do
        project = create(:project, :with_avatar)
        create(:environment, project: project, name: 'review/test-feature', state: :available)
        environment = create(:environment, project: project, name: 'review/another-feature', state: :available)
        create(:environment, project: project, name: 'review/great-feature', state: :stopped)
        project.add_developer(user)
        user.update!(ops_dashboard_projects: [project])

        get :environments_list

        project_json = json_response['projects'].first
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('dashboard/operations/environments_list', dir: 'ee')
        expect(project_json['environments'].count).to eq(1)
        expect(project_json['environments'].first['size']).to eq(2)
        expect(project_json['environments'].first['within_folder']).to eq(true)
        expect(project_json['environments'].first['id']).to eq(environment.id)
      end

      it 'groups environments scoped to projects' do
        project1 = create(:project)
        project2 = create(:project)
        create(:environment, project: project1, name: 'review/test')
        create(:environment, project: project2, name: 'review/test')
        environment = create(:environment, project: project2, name: 'review/something')
        project2.add_developer(user)
        user.update!(ops_dashboard_projects: [project2])

        get :environments_list

        project_json = json_response['projects'].first
        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to match_response_schema('dashboard/operations/environments_list', dir: 'ee')
        expect(project_json['environments'].count).to eq(1)
        expect(project_json['environments'].first['size']).to eq(2)
        expect(project_json['environments'].first['within_folder']).to eq(true)
        expect(project_json['environments'].first['id']).to eq(environment.id)
      end
    end
  end

  describe 'POST #create' do
    it_behaves_like 'unlicensed', :post, :create

    context 'without added projects' do
      let(:project_a) { create(:project) }
      let(:project_b) { create(:project) }

      before do
        project_a.add_developer(user)
        project_b.add_developer(user)
      end

      it 'adds projects to the dasboard' do
        post :create, params: { project_ids: [project_a.id, project_b.id.to_s] }

        expect(response).to have_gitlab_http_status(200)
        expect(json_response).to match_schema('dashboard/operations/add', dir: 'ee')
        expect(json_response['added']).to contain_exactly(project_a.id, project_b.id)
        expect(json_response['duplicate']).to be_empty
        expect(json_response['invalid']).to be_empty

        user.reload
        expect(user.ops_dashboard_projects).to contain_exactly(project_a, project_b)
      end

      it 'cannot add a project twice' do
        post :create, params: { project_ids: [project_a.id, project_a.id] }

        expect(response).to have_gitlab_http_status(200)
        expect(json_response).to match_schema('dashboard/operations/add', dir: 'ee')
        expect(json_response['added']).to contain_exactly(project_a.id)
        expect(json_response['duplicate']).to be_empty
        expect(json_response['invalid']).to be_empty

        user.reload
        expect(user.ops_dashboard_projects).to eq([project_a])
      end

      it 'does not add invalid project ids' do
        post :create, params: { project_ids: ['', -1, '-2'] }

        expect(response).to have_gitlab_http_status(200)
        expect(json_response).to match_schema('dashboard/operations/add', dir: 'ee')
        expect(json_response['added']).to be_empty
        expect(json_response['duplicate']).to be_empty
        expect(json_response['invalid']).to contain_exactly('', '-1', '-2')

        user.reload
        expect(user.ops_dashboard_projects).to be_empty
      end
    end

    context 'with added project' do
      let(:project) { create(:project) }

      before do
        user.ops_dashboard_projects << project
        project.add_developer(user)
      end

      it 'does not add already added project' do
        post :create, params: { project_ids: [project.id] }

        expect(response).to have_gitlab_http_status(200)
        expect(json_response).to match_schema('dashboard/operations/add', dir: 'ee')
        expect(json_response['added']).to be_empty
        expect(json_response['duplicate']).to contain_exactly(project.id)
        expect(json_response['invalid']).to be_empty

        user.reload
        expect(user.ops_dashboard_projects).to eq([project])
      end
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        post :create

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    it_behaves_like 'unlicensed', :delete, :destroy

    context 'with added projects' do
      let(:project) { create(:project) }

      before do
        user.ops_dashboard_projects << project
      end

      it 'removes a project successfully' do
        delete :destroy, params: { project_id: project.id }

        expect(response).to have_gitlab_http_status(200)

        user.reload
        expect(user.ops_dashboard_projects).not_to eq([project])
      end
    end

    context 'without projects' do
      it 'cannot remove invalid project' do
        delete :destroy, params: { project_id: -1 }

        expect(response).to have_gitlab_http_status(204)
      end
    end

    context 'with an anonymous user' do
      before do
        sign_out(user)
      end

      it 'redirects to sign-in page' do
        delete :destroy

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
