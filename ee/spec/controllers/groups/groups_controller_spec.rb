require 'spec_helper'

describe GroupsController do
  include ExternalAuthorizationServiceHelpers

  let(:user) { create(:user) }
  let(:group) { create(:group) }

  before do
    group.add_owner(user)
    sign_in(user)
  end

  context 'with external authorization service enabled' do
    before do
      enable_external_authorization_service_check
    end

    describe 'GET #show' do
      it 'is successful' do
        get :show, params: { id: group.to_param }

        expect(response).to have_gitlab_http_status(200)
      end

      it 'does not allow other formats' do
        get :show, params: { id: group.to_param }, format: :atom

        expect(response).to have_gitlab_http_status(403)
      end
    end

    describe 'GET #edit' do
      it 'is successful' do
        get :edit, params: { id: group.to_param }

        expect(response).to have_gitlab_http_status(200)
      end
    end

    describe 'GET #new' do
      it 'is successful' do
        get :new

        expect(response).to have_gitlab_http_status(200)
      end
    end

    describe 'GET #index' do
      it 'is successful' do
        get :index

        # Redirects to the dashboard
        expect(response).to have_gitlab_http_status(302)
      end
    end

    describe 'POST #create' do
      it 'creates a group' do
        expect do
          post :create, params: { group: { name: 'a name', path: 'a-name' } }
        end.to change { Group.count }.by(1)
      end
    end

    describe 'PUT #update' do
      it 'updates a group' do
        expect do
          put :update, params: { id: group.to_param, group: { name: 'world' } }
        end.to change { group.reload.name }
      end

      context 'no license' do
        it 'does not update the file_template_project_id successfully' do
          project = create(:project, group: group)

          stub_licensed_features(custom_file_templates_for_namespace: false)

          expect do
            post :update, params: { id: group.to_param, group: { file_template_project_id: project.id } }
          end.not_to change { group.reload.file_template_project_id }
        end

        it 'does not update insight project_id successfully' do
          project = create(:project, group: group)

          stub_licensed_features(insights: false)

          post :update, params: { id: group.to_param, group: { insight_attributes: { project_id: project.id } } }

          expect(group.reload.insight).to be_nil
        end
      end

      context 'with license' do
        it 'updates the file_template_project_id successfully' do
          project = create(:project, group: group)

          stub_licensed_features(custom_file_templates_for_namespace: true)

          expect do
            post :update, params: { id: group.to_param, group: { file_template_project_id: project.id } }
          end.to change { group.reload.file_template_project_id }.to(project.id)
        end

        it 'updates insight project_id successfully' do
          project = create(:project, group: group)

          stub_licensed_features(insights: true)

          post :update, params: { id: group.to_param, group: { insight_attributes: { project_id: project.id } } }

          expect(group.reload.insight.project).to eq(project)
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'deletes the group' do
        delete :destroy, params: { id: group.to_param }

        expect(response).to have_gitlab_http_status(302)
      end
    end
  end

  context 'with sso enforcement enabled' do
    let(:group) { create(:group, :private) }
    let(:guest_user) { create(:user) }
    let!(:saml_provider) { create(:saml_provider, group: group, enforced_sso: true) }

    before do
      group.add_guest(guest_user)
      sign_in(guest_user)
    end

    context 'without SAML session' do
      it 'prevents access to group resources' do
        get :show, params: { id: group.to_param }

        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'with active SAML session' do
      let(:enforcer) { Gitlab::Auth::GroupSaml::SessionEnforcer.new(session, saml_provider) }

      before do
        enforcer.update_session
      end

      it 'allows access to group resources' do
        get :show, params: { id: group.to_param }

        expect(response).to have_gitlab_http_status(200)
      end
    end
  end

  describe 'GET #activity' do
    subject { get :activity, params: { id: group.to_param } }

    it_behaves_like 'disabled when using an external authorization service'
  end

  describe 'GET #issues' do
    subject { get :issues, params: { id: group.to_param } }

    it_behaves_like 'disabled when using an external authorization service'
  end

  describe 'GET #merge_requests' do
    subject { get :merge_requests, params: { id: group.to_param } }

    it_behaves_like 'disabled when using an external authorization service'
  end
end
