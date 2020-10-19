# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IterationsController do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  describe 'index' do
    context 'when iterations license is not available' do
      before do
        stub_licensed_features(iterations: false)
        sign_in(user)
        get :index, params: { namespace_id: project.namespace, project_id: project }
      end

      it 'renders 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is unauthorized' do
      before do
        sign_in(user)
        get :index, params: { namespace_id: project.namespace, project_id: project }
      end

      it 'renders 404' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    context 'when user is authorized' do
      before do
        project.add_developer(user)
        sign_in(user)
        get :index, params: { namespace_id: project.namespace, project_id: project }
      end

      it 'renders index successfully' do
        expect(response).to be_successful
      end
    end
  end
end
