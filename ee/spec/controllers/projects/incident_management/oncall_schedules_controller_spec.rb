# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IncidentManagement::OncallSchedulesController do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  describe 'GET #index' do
    let(:request) do
      get :index, params: { project_id: project.to_param, namespace_id: project.namespace.to_param }
    end

    context 'authorized' do
      before do
        project.add_maintainer(user)
        sign_in(user)
      end

      it 'renders index with 200 status code' do
        request

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:index)
      end
    end

    context 'unauthorized' do
      before do
        sign_in(user)
      end

      it 'responds with 404' do
        request

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
