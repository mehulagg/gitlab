# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::SastConfigurationController do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, namespace: group) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }

  before_all do
    group.add_developer(developer)
    group.add_guest(guest)
  end

  before do
    stub_licensed_features(security_dashboard: true)
  end

  describe 'GET #show' do
    subject(:request) { get :show, params: { namespace_id: project.namespace, project_id: project } }

    render_views

    include_context '"Security & Compliance" permissions' do
      let(:valid_request) { request }

      before_request do
        sign_in(developer)
      end
    end

    it_behaves_like SecurityDashboardsPermissions do
      let(:vulnerable) { project }
      let(:security_dashboard_action) { request }
    end

    context 'with authorized user' do
      before do
        sign_in(developer)
      end

      it 'renders the show template' do
        request

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:show)
      end

      it 'renders the side navigation with the correct submenu set as active' do
        request

        expect(response.body).to have_active_sub_navigation('Configuration')
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(guest)
      end

      it 'returns a 403' do
        request

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end

  describe 'POST #create' do
    let(:params) do
      {
        namespace_id: project.namespace.to_param,
        project_id: project.to_param,
        sast_configuration: {
          secure_analyzers_prefix: 'localhost:5000/analyzers',
          sast_analyzer_image_tag: '1',
          sast_excluded_paths: 'docs',
          stage: 'security',
          search_max_depth: 11
        },
        format: :json
      }
    end

    subject(:request) { post :create, params: params, as: :json }

    before do
      sign_in(developer)
    end

    include_context '"Security & Compliance" permissions' do
      let(:valid_request) { request }
    end

    context 'with valid params' do
      it 'returns the new merge request url' do
        request

        expect(json_response["message"]).to eq("success")
        expect(json_response["filePath"]).to match(/#{Gitlab::Routing.url_helpers.project_new_merge_request_url(project, {})}(.*)description(.*)source_branch/)
      end
    end
  end
end
