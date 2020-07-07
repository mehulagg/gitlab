# frozen_string_literal: true

require 'spec_helper'

# rspec spec/controllers/projects/product_analytics_controller_spec.rb

describe Projects::ProductAnalyticsController do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
    project.add_maintainer(user)
  end

  describe 'GET #index' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end

      context 'with an anonymous user' do
        before do
          sign_out(user)
        end

        it 'redirects to sign-in page' do
          get :index, params: project_params

          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'GET #users' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #activity' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #test' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #example' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #users' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #users' do
    describe 'html' do
      it 'renders index with 200 status code' do
        get :index, params: project_params

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end
  end

  private

  def issue_params(opts = {})
    project_params.reverse_merge(opts)
  end

  def project_params(opts = {})
    opts.reverse_merge(namespace_id: project.namespace, project_id: project)
  end
end
