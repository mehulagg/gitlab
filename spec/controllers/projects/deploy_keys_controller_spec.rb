require 'spec_helper'

describe Projects::DeployKeysController do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)

    sign_in(user)
  end

  describe 'GET index' do
    let(:params) do
      { namespace_id: project.namespace, project_id: project }
    end

    context 'when html requested' do
      it 'redirects to blob' do
        get :index, params: params

        expect(response).to redirect_to(project_settings_repository_path(project, anchor: 'js-deploy-keys-settings'))
      end
    end

    context 'when json requested' do
      let(:project2) { create(:project, :internal)}
      let(:project_private) { create(:project, :private)}

      let(:deploy_key_internal) { create(:deploy_key) }
      let(:deploy_key_actual) { create(:deploy_key) }
      let!(:deploy_key_public) { create(:deploy_key, public: true) }

      let!(:deploy_keys_project_internal) do
        create(:deploy_keys_project, project: project2, deploy_key: deploy_key_internal)
      end

      let!(:deploy_keys_actual_project) do
        create(:deploy_keys_project, project: project, deploy_key: deploy_key_actual)
      end

      let!(:deploy_keys_project_private) do
        create(:deploy_keys_project, project: project_private, deploy_key: create(:another_deploy_key))
      end

      before do
        project2.add_developer(user)
      end

      it 'returns json in a correct format' do
        get :index, params: params.merge(format: :json)

        json = JSON.parse(response.body)

        expect(json.keys).to match_array(%w(enabled_keys available_project_keys public_keys))
        expect(json['enabled_keys'].count).to eq(1)
        expect(json['available_project_keys'].count).to eq(1)
        expect(json['public_keys'].count).to eq(1)
      end
    end
  end

  describe '/enable/:id' do
    let(:deploy_key) { create(:deploy_key) }
    let(:project2) { create(:project) }
    let!(:deploy_keys_project_internal) do
      create(:deploy_keys_project, project: project2, deploy_key: deploy_key)
    end

    context 'with anonymous user' do
      before do
        sign_out(:user)
      end

      it 'redirects to login' do
        expect do
          put :enable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }
        end.not_to change { DeployKeysProject.count }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with user with no permission' do
      before do
        sign_in(create(:user))
      end

      it 'returns 404' do
        expect do
          put :enable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }
        end.not_to change { DeployKeysProject.count }

        expect(response).to have_http_status(404)
      end
    end

    context 'with user with permission' do
      before do
        project2.add_maintainer(user)
      end

      it 'returns 302' do
        expect do
          put :enable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }
        end.to change { DeployKeysProject.count }.by(1)

        expect(DeployKeysProject.where(project_id: project.id, deploy_key_id: deploy_key.id).count).to eq(1)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(namespace_project_settings_repository_path(anchor: 'js-deploy-keys-settings'))
      end

      it 'returns 404' do
        put :enable, params: { id: 0, namespace_id: project.namespace, project_id: project }

        expect(response).to have_http_status(404)
      end
    end

    context 'with admin' do
      before do
        sign_in(create(:admin))
      end

      it 'returns 302' do
        expect do
          put :enable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }
        end.to change { DeployKeysProject.count }.by(1)
           .and change { AuditEvent.count }.by(1) ## EE only

        expect(DeployKeysProject.where(project_id: project.id, deploy_key_id: deploy_key.id).count).to eq(1)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(namespace_project_settings_repository_path(anchor: 'js-deploy-keys-settings'))
      end
    end
  end

  describe '/disable/:id' do
    let(:deploy_key) { create(:deploy_key) }
    let!(:deploy_key_project) { create(:deploy_keys_project, project: project, deploy_key: deploy_key) }

    context 'with anonymous user' do
      before do
        sign_out(:user)
      end

      it 'redirects to login' do
        put :disable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
        expect(DeployKey.find(deploy_key.id)).to eq(deploy_key)
      end
    end

    context 'with user with no permission' do
      before do
        sign_in(create(:user))
      end

      it 'returns 404' do
        put :disable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }

        expect(response).to have_http_status(404)
        expect(DeployKey.find(deploy_key.id)).to eq(deploy_key)
      end
    end

    context 'with user with permission' do
      it 'returns 302' do
        put :disable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(namespace_project_settings_repository_path(anchor: 'js-deploy-keys-settings'))

        expect { DeployKey.find(deploy_key.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns 404' do
        put :disable, params: { id: 0, namespace_id: project.namespace, project_id: project }

        expect(response).to have_http_status(404)
      end
    end

    context 'with admin' do
      before do
        sign_in(create(:admin))
      end

      it 'returns 302' do
        expect do
          put :disable, params: { id: deploy_key.id, namespace_id: project.namespace, project_id: project }
        end.to change { DeployKey.count }.by(-1)
           .and change { AuditEvent.count }.by(1) ## EE only

        expect(response).to have_http_status(302)
        expect(response).to redirect_to(namespace_project_settings_repository_path(anchor: 'js-deploy-keys-settings'))

        expect { DeployKey.find(deploy_key.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
