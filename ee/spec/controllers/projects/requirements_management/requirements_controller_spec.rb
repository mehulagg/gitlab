# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::RequirementsManagement::RequirementsController do
  let_it_be(:user) { create(:user) }

  subject { get :index, params: { namespace_id: project.namespace, project_id: project } }

  describe 'GET #index' do
    context 'private project' do
      let(:project) { create(:project) }

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

    context 'public project' do
      let(:project) { create(:project, :public) }

      before do
        stub_licensed_features(requirements: true)
      end

      context 'with requirements disabled' do
        before do
          project.project_feature.update!({ requirements_access_level: ::ProjectFeature::DISABLED })
          project.add_developer(user)
          sign_in(user)
        end

        it 'returns 404' do
          subject

          expect(response).to have_gitlab_http_status(:not_found)
        end
      end

      context 'with requirements visible to project memebers' do
        before do
          project.project_feature.update!({ requirements_access_level: ::ProjectFeature::PRIVATE })
        end

        context 'with authorized user' do
          before do
            project.add_developer(user)
            sign_in(user)
          end

          it 'renders the index template' do
            subject

            expect(response).to have_gitlab_http_status(:ok)
            expect(response).to render_template(:index)
          end
        end

        context 'with unauthorized user' do
          before do
            sign_in(user)
          end

          it 'returns 404' do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context 'with requirements visible to everyone' do
        before do
          project.project_feature.update!({ requirements_access_level: ::ProjectFeature::ENABLED })
        end

        context 'with anonymous user' do
          it 'renders the index template' do
            subject

            expect(response).to have_gitlab_http_status(:ok)
            expect(response).to render_template(:index)
          end
        end
      end
    end
  end
end
