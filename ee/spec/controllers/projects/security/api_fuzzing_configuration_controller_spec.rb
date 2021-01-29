# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::ApiFuzzingConfigurationController do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }

  before_all do
    group.add_developer(developer)
    group.add_guest(guest)
  end

  describe 'GET #show' do
    subject(:request) { get :show, params: { namespace_id: project.namespace, project_id: project } }

    render_views

    it_behaves_like SecurityDashboardsPermissions do
      let(:vulnerable) { project }
      let(:security_dashboard_action) { request }
    end

    context 'with authorized user' do
      before do
        stub_licensed_features(security_dashboard: true)

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

      context 'with feature flag disabled' do
        before do
          stub_feature_flags(api_fuzzing_configuration_ui: false)
        end

        it 'returns a 404 for an HTML request' do
          request

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with unauthorized user' do
      before do
        stub_licensed_features(security_dashboard: true)

        sign_in(guest)
      end

      it 'returns a 403' do
        request

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
