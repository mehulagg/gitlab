# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::DastSiteProfilesController, type: :request do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:dast_site_profile) { create(:dast_site_profile, project: project) }

  def with_feature_available
    stub_licensed_features(security_on_demand_scans: true)
  end

  def with_user_authorized
    project.add_developer(user)
    login_as(user)
  end

  shared_examples 'a GET request' do
    context 'feature available' do
      before do
        with_feature_available
      end

      context 'user authorized' do
        before do
          with_user_authorized
        end

        it 'can access page' do
          get path

          expect(response).to have_gitlab_http_status(:ok)
        end
      end

      context 'user not authorized' do
        before do
          project.add_guest(user)

          login_as(user)
        end

        it 'sees a 404 error' do
          get path

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'feature not available' do
      before do
        with_user_authorized
      end

      context 'license doesnt\'t support the feature' do
        it 'sees a 404 error' do
          stub_licensed_features(security_on_demand_scans: false)
          get path

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end
  end

  describe 'GET #new' do
    it_behaves_like 'a GET request' do
      let(:path) { new_project_security_configuration_dast_profiles_dast_site_profile_path(project) }
    end
  end

  describe 'GET #edit' do
    let(:edit_path) { edit_project_security_configuration_dast_profiles_dast_site_profile_path(project, dast_site_profile) }

    it_behaves_like 'a GET request' do
      let(:path) { edit_path }
    end
  end
end
