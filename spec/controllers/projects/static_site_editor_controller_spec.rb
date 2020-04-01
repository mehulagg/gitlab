# frozen_string_literal: true

require 'spec_helper'

describe Projects::StaticSiteEditorController do
  let(:project) { create(:project, :public, :repository) }

  describe 'GET edit' do
    let(:default_params) do
      {
        namespace_id: project.namespace,
        project_id: project,
        id: 'master/README.md'
      }
    end

    context 'User roles' do
      context 'anonymous' do
        before do
          get :edit, params: default_params
        end

        it 'redirects to sign in and returns' do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'as guest' do
        let(:guest) { create(:user) }

        before do
          sign_in(guest)
          get :edit, params: default_params
        end

        it 'renders 404' do
          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'as developer' do
        let(:developer) { create(:user) }

        before do
          project.add_developer(developer)
          sign_in(developer)
          get :edit, params: default_params
        end

        it 'renders the edit page' do
          expect(response).to have_gitlab_http_status(:ok)
        end

        it { expect(assigns(:errors)).to be_nil }
      end

      context 'as maintainer' do
        let(:maintainer) { create(:user) }

        before do
          project.add_maintainer(maintainer)
          sign_in(maintainer)
          get :edit, params: default_params
        end

        it 'renders the edit page' do
          expect(response).to have_gitlab_http_status(:ok)
        end

        it { expect(assigns(:errors)).to be_nil }
      end
    end

    context 'when user has permissions to edit' do
      let(:maintainer) { create(:user) }

      before do
        project.add_maintainer(maintainer)
        sign_in(maintainer)
      end

      context 'when there is a validation error' do
        before do
          get :edit, params: default_params.merge(id: 'master/UNKNOWN')
        end

        it { expect(response).to have_gitlab_http_status(:ok) }
        it { expect(assigns(:errors)).to have_key(:file) }
      end
    end
  end
end
