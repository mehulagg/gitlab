# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Quality::TestCasesController do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  shared_examples_for 'test case action' do |template|
    context 'with authorized user' do
      before do
        project.add_developer(user)
        sign_in(user)
      end

      context 'when feature is available' do
        before do
          stub_licensed_features(quality_management: true)
        end

        it 'renders the template' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(template)
        end

        context 'when quality_test_cases flag is disabled' do
          before do
            stub_feature_flags(quality_test_cases: false)
          end

          it 'returns 404' do
            subject

            expect(response).to have_gitlab_http_status(:not_found)
          end
        end
      end

      context 'when feature is not available' do
        before do
          stub_licensed_features(quality_management: false)
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
          stub_licensed_features(quality_management: true)
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

  describe 'GET' do
    describe '#index' do
      subject { get :index, params: { namespace_id: project.namespace, project_id: project } }

      it_behaves_like 'test case action', :index
    end

    describe '#new' do
      subject { get :new, params: { namespace_id: project.namespace, project_id: project } }

      it_behaves_like 'test case action', :new
    end

    describe '#show' do
      let_it_be(:test_case) { create(:quality_test_case, project: project) }

      subject { get :show, params: { namespace_id: project.namespace, project_id: project, id: test_case } }

      it_behaves_like 'test case action', :show

      context 'when feature is enabled and user has access' do
        before do
          stub_licensed_features(quality_management: true)
          project.add_developer(user)
          sign_in(user)
        end

        it 'assigns test case related variables' do
          subject

          expect(assigns(:test_case)).to eq(test_case)
          expect(assigns(:issuable_sidebar)).to be_present
        end
      end
    end
  end
end
