# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IncidentsController do
  let_it_be(:project) { create(:project) }
  let_it_be(:developer) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:anonymous) { nil }

  before_all do
    project.add_developer(developer)
    project.add_guest(guest)
  end

  before do
    sign_in(user) if user
    make_request
  end

  describe 'GET #index' do
    def make_request
      get :index, params: project_params
    end

    let(:user) { developer }

    it 'shows the page' do
      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:index)
    end

    context 'when user is unauthorized' do
      let(:user) { anonymous }

      it 'redirects to the login page' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is a guest' do
      let(:user) { guest }

      it 'shows 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end

  describe 'GET #show' do
    def make_request
      get :show, params: project_params(id: resource_id)
    end

    let_it_be(:resource) { create(:incident, project: project) }
    let(:resource_id) { resource.id }
    let(:user) { developer }

    it 'renders incident page' do
      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:show)

      expect(assigns(:incident)).to be_present
      expect(assigns(:incident).author.association(:status)).to be_loaded
      expect(assigns(:issue)).to be_present # hack to make copied HAML view work
      expect(assigns(:noteable)).to eq(assigns(:incident))
    end

    context 'with invalid id' do
      let(:resource_id) { non_existing_record_id }

      it 'shows 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'for issue' do
      let_it_be(:resource) { create(:issue, project: project) }

      it 'shows 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'without permissions' do
      let(:user) { guest }

      it 'shows 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when unauthorized' do
      let(:user) { anonymous }

      it 'shows 404' do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  private

  def project_params(opts = {})
    opts.reverse_merge(namespace_id: project.namespace, project_id: project)
  end
end
