# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::DashboardController do
  let_it_be(:group)   { create(:group) }
  let_it_be(:project) { create(:project, :repository, :public, namespace: group) }
  let_it_be(:user)    { create(:user) }

  it_behaves_like SecurityDashboardsPermissions do
    let(:vulnerable) { project }

    let(:security_dashboard_action) do
      get :index, params: { namespace_id: project.namespace, project_id: project }
    end
  end

  before do
    group.add_developer(user)
    stub_licensed_features(security_dashboard: true)
  end

  describe 'GET #index' do
    let(:pipeline) { create(:ci_pipeline, sha: project.commit.id, project: project, user: user) }

    render_views

    def show_security_dashboard(current_user = user)
      sign_in(current_user)
      get :index, params: { namespace_id: project.namespace, project_id: project }
    end

    context 'when project has no vulnerabilities' do
      it 'renders empty state' do
        show_security_dashboard

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
        expect(response.body).to have_css('div#js-security-report-app[data-has-vulnerabilities="false"]')
      end
    end

    context 'when project has vulnerabilities' do
      before do
        create(:vulnerability, project: project)
      end

      it 'renders dashboard with vulnerability metadata' do
        show_security_dashboard

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
        expect(response.body).to have_css('div#js-security-report-app[data-has-vulnerabilities="true"]')
      end
    end
  end
end
