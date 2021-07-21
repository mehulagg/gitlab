# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::PoliciesController do
  let_it_be(:owner) { create(:user) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project, reload: true) { create(:project, namespace: owner.namespace) }
  let_it_be(:policy) { project }
  # Still not working...
  # Try looking at ./ee/spec/graphql/resolvers/scan_execution_policy_spec.rb
  # Might need to create new factory for scan execution policies in ./ee/spec/factories/
  # See ./ee/spec/factories/security_orchestration_policy_configurations.rb

  before do
    project.add_developer(user)
    sign_in(user)
  end

  describe 'GET #edit' do
    subject(:request) { get :edit, params: { namespace_id: project.namespace, project_id: project, id: policy.name } }

    context 'with authorized user' do
      context 'when feature is available' do
        before do
          stub_feature_flags(security_orchestration_policies_configuration: true)
          stub_licensed_features(security_orchestration_policies: true)
        end

        it 'renders the new template' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:edit)
        end
      end

      context 'when feature is not available' do
        before do
          stub_feature_flags(security_orchestration_policies_configuration: false)
          stub_licensed_features(security_orchestration_policies: false)
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
          stub_feature_flags(security_orchestration_policies_configuration: true)
          stub_licensed_features(security_orchestration_policies: true)
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

  describe 'GET #show' do
    using RSpec::Parameterized::TableSyntax

    where(:feature_flag, :license, :status) do
      true | true | :ok
      false | false | :not_found
      false | true | :not_found
      true | false | :not_found
    end

    subject(:request) { get :show, params: { namespace_id: project.namespace, project_id: project} }

    with_them do
      before do
        stub_feature_flags(security_orchestration_policies_configuration: feature_flag)
        stub_licensed_features(security_orchestration_policies: license)
      end

      specify do
        subject

        expect(response).to have_gitlab_http_status(status)
      end
    end
  end
end
