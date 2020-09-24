# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::RequirementsManagement::RequirementsController do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  subject { get :index, params: { namespace_id: project.namespace, project_id: project } }

  describe 'GET #index' do
    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(requirements: true)
        end

        it 'renders the index template' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:index)
        end

        context 'when requirements_management flag is disabled' do
          before do
            stub_feature_flags(requirements_management: false)
          end

          it 'returns 404' do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context 'when feature is not available' do
        before do
          stub_licensed_features(requirements: false)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with unauthorized user' do
      before do
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(requirements: true)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end
    end

    context 'with anonymous user' do
      it 'returns 302' do
        subject

        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
