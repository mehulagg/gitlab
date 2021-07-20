# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::PoliciesController, type: :request do
  let_it_be(:owner) { create(:user) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project, reload: true) { create(:project, namespace: owner.namespace) }

  before do
    project.add_developer(user)
    login_as(user)
  end

  context 'displaying page' do
    using RSpec::Parameterized::TableSyntax

    where(:feature_flag, :license, :status) do
      true | true | :ok
      false | false | :not_found
      false | true | :not_found
      true | false | :not_found
    end

    subject { get project_security_policy_url(project) }

    with_them do
      before do
        stub_feature_flags(security_orchestration_policies_configuration: feature_flag)
        stub_licensed_features(security_orchestration_policies: license)
      end

      specify do
        get project_security_policy_url(project)

        expect(response).to have_gitlab_http_status(status)
      end
    end
  end

  context 'assign action' do
    let_it_be(:policy_project, reload: true) { create(:project) }

    before do
      stub_feature_flags(security_orchestration_policies_configuration: true)
      stub_licensed_features(security_orchestration_policies: true)
    end

    context 'when user is not an owner of the project' do
      it 'returns error message' do
        post assign_project_security_policy_url(project), params: { orchestration: { policy_project_id: policy_project.id } }

        expect(response).to have_gitlab_http_status(:not_found)
        expect(response).not_to render_template('new')
      end
    end

    context 'when user is an owner of the project' do
      before do
        login_as(owner)
      end

      it 'assigns policy project to project' do
        post assign_project_security_policy_url(project), params: { orchestration: { policy_project_id: policy_project.id } }

        expect(response).to redirect_to(project_security_policy_url(project))
        expect(project.security_orchestration_policy_configuration.security_policy_management_project_id).to eq(policy_project.id)
      end

      it 'returns error message for invalid input' do
        post assign_project_security_policy_url(project), params: { orchestration: { policy_project_id: nil } }

        expect(flash[:alert]).to eq 'Policy project doesn\'t exist'
      end
    end
  end
end
