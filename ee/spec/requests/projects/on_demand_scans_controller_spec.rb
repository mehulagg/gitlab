# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::OnDemandScansController, type: :request do
  let_it_be(:project) { create(:project) }
  let(:user) { create(:user) }

  shared_examples 'on-demand scans page' do
    context 'feature available' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'user authorized' do
        before do
          project.add_developer(user)

          login_as(user)
        end

        it "can access page" do
          get path

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'user not authorized' do
        before do
          project.add_guest(user)

          login_as(user)
        end

        it "sees a 404 error" do
          get path

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'feature not available' do
      before do
        project.add_developer(user)

        login_as(user)
      end

      it "sees a 404 error if the license doesn't support the feature" do
        stub_licensed_features(security_on_demand_scans: false)
        get path

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'GET #index' do
    it_behaves_like 'on-demand scans page' do
      let(:path) { project_on_demand_scans_path(project) }
    end
  end

  describe 'GET #new' do
    it_behaves_like 'on-demand scans page' do
      let(:path) { new_project_on_demand_scan_path(project) }
    end
  end

  describe 'GET #edit' do
    it_behaves_like 'on-demand scans page' do
      # This should be improved as part of https://gitlab.com/gitlab-org/gitlab/-/issues/295242
      let(:path) { edit_project_on_demand_scan_path(project, id: 1) }
    end
  end
end
