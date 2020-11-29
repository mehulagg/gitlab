# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::DastProfilesController, type: :request do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  describe 'GET #index' do
    context 'feature available' do
      before do
        stub_licensed_features(security_on_demand_scans: true)
      end

      context 'user authorized' do
        before do
          project.add_developer(user)

          login_as(user)
        end

        it 'can access page' do
          get project_security_configuration_dast_profiles_path(project)

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'user not authorized' do
        before do
          project.add_guest(user)

          login_as(user)
        end

        it 'sees a 404 error' do
          get project_security_configuration_dast_profiles_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'feature not available' do
      before do
        project.add_developer(user)

        login_as(user)
      end

      context 'license doesnt\'t support the feature' do
        it 'sees a 404 error' do
          stub_licensed_features(security_on_demand_scans: false)
          get project_security_configuration_dast_profiles_path(project)

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end
end
