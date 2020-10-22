# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::OnDemandScansController, type: :request do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  describe 'GET #index' do
    context 'feature available' do
      before do
        stub_feature_flags(security_on_demand_scans_feature_flag: true)
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'user authorized' do
        before do
          project.add_developer(user)

          login_as(user)
        end

        it "can access page" do
          get project_on_demand_scans_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'user not authorized' do
        before do
          project.add_guest(user)

          login_as(user)
        end

        it "sees a 404 error" do
          get project_on_demand_scans_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'feature not available' do
      before do
        project.add_developer(user)

        login_as(user)
      end

      it "sees a 404 error if the feature flag is disabled" do
        stub_feature_flags(security_on_demand_scans_feature_flag: false)
        stub_licensed_features(security_on_demand_scans: true)
        get project_on_demand_scans_path(project)

        expect(response).to have_gitlab_http_status(:not_found)
      end

      it "sees a 404 error if the license doesn't support the feature" do
        stub_feature_flags(security_on_demand_scans_feature_flag: true)
        stub_licensed_features(security_on_demand_scans: false)
        get project_on_demand_scans_path(project)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
