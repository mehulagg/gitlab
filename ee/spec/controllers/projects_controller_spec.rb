# frozen_string_literal: true

require 'spec_helper'

describe ProjectsController do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  shared_examples_for 'action pushing protected branches data to gon' do
    include_context 'gon'

    let!(:protected_branch) { create(:protected_branch, project: project) }
    let!(:another_protected_branch) { create(:protected_branch, project: project) }
    let!(:unrelated_protected_branch) { create(:protected_branch) }

    before do
      action
    end

    it 'pushes protected branches data to gon' do
      expect(gon['protected_branches']).to match_array([
        { id: protected_branch.id, name: protected_branch.name },
        { id: another_protected_branch.id, name: another_protected_branch.name }
      ])
    end
  end

  describe "GET show" do
    let(:public_project) { create(:project, :public, :repository) }

    render_views

    it 'shows the over size limit warning message if above_size_limit' do
      allow_any_instance_of(EE::Project).to receive(:above_size_limit?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :show, params: { namespace_id: public_project.namespace.path, id: public_project.path }

      expect(response.body).to match(/The size of this repository.+exceeds the limit/)
    end

    it 'does not show an over size warning if not above_size_limit' do
      get :show, params: { namespace_id: public_project.namespace.path, id: public_project.path }

      expect(response.body).not_to match(/The size of this repository.+exceeds the limit/)
    end
  end

  describe 'GET edit' do
    let(:action) do
      get :edit,
          params: {
            namespace_id: project.namespace.path,
            id: project.path
          }
    end

    it_behaves_like 'action pushing protected branches data to gon'

    it 'does not allow an auditor user to access the page' do
      sign_in(create(:user, :auditor))
      action

      expect(response).to have_gitlab_http_status(:not_found)
    end
  end

  describe 'POST create' do
    let!(:params) do
      {
        path: 'foo',
        description: 'bar',
        import_url: project.http_url_to_repo,
        namespace_id: user.namespace.id,
        visibility_level: Gitlab::VisibilityLevel::PUBLIC,
        mirror: true,
        mirror_trigger_builds: true
      }
    end

    context 'with licensed repository mirrors' do
      before do
        stub_licensed_features(repository_mirrors: true)
      end

      it 'has mirror enabled in new project' do
        post :create, params: { project: params }

        created_project = Project.find_by_path('foo')
        expect(created_project.reload.mirror).to be true
        expect(created_project.reload.mirror_user.id).to eq(user.id)
      end
    end

    context 'with unlicensed repository mirrors' do
      before do
        stub_licensed_features(repository_mirrors: false)
      end

      it 'has mirror disabled in new project' do
        post :create, params: { project: params }

        created_project = Project.find_by_path('foo')
        expect(created_project.reload.mirror).to be false
        expect(created_project.reload.mirror_user).to be nil
      end
    end

    context 'custom project templates' do
      let(:group) { create(:group) }
      let(:project_template) { create(:project, :repository, :public, namespace: group) }
      let(:templates_params) do
        {
          path: 'foo',
          description: 'bar',
          namespace_id: user.namespace.id,
          use_custom_template: true,
          template_name: project_template.name
        }
      end

      context 'when licensed' do
        before do
          stub_licensed_features(custom_project_templates: true)
          stub_ee_application_setting(custom_project_templates_group_id: group.id)
        end

        context 'object storage' do
          before do
            stub_uploads_object_storage(FileUploader)
          end

          it 'creates the project from project template', :sidekiq_might_not_need_inline do
            post :create, params: { project: templates_params }

            created_project = Project.find_by_path('foo')
            expect(flash[:notice]).to eq "Project 'foo' was successfully created."
            expect(created_project.repository.empty?).to be false
          end
        end
      end

      context 'when unlicensed' do
        render_views

        before do
          stub_licensed_features(custom_project_templates: false)
          project
          project_template
        end

        it 'does not create the project from project template' do
          expect { post :create, params: { project: templates_params } }.not_to change { Project.count }

          expect(response).to have_gitlab_http_status(:ok)
          expect(response.body).to match(/Template name .* is unknown or invalid/)
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:params) { { repository_size_limit: 1024 } }

    let(:action) do
      put :update,
          params: {
            namespace_id: project.namespace,
            id: project,
            project: params
          }
    end

    it 'updates EE attributes' do
      action
      project.reload

      expect(response).to have_gitlab_http_status(:found)
      params.except(:repository_size_limit).each do |param, value|
        expect(project.public_send(param)).to eq(value)
      end
      expect(project.repository_size_limit).to eq(params[:repository_size_limit].megabytes)
    end

    context 'when Merge Request Approvers related params are set' do
      let(:params) do
        {
          approvals_before_merge: 50,
          approver_group_ids: create(:group).id,
          approver_ids: create(:user).id,
          reset_approvals_on_push: false
        }
      end

      it 'updates Merge Request Approvers attributes' do
        action
        project.reload

        expect(response).to have_gitlab_http_status(:found)
        expect(project.approver_groups.pluck(:group_id)).to contain_exactly(params[:approver_group_ids])
        expect(project.approvers.pluck(:user_id)).to contain_exactly(params[:approver_ids])
      end
    end

    context 'when Issuable Default Templates params are set' do
      let(:params) do
        {
          issues_template: 'You got issues?',
          merge_requests_template: 'I got tissues'
        }
      end

      it 'updates Issuable Default Templates attributes' do
        action
        project.reload

        expect(response).to have_gitlab_http_status(:found)
        params.each do |param, value|
          expect(project.public_send(param)).to eq(value)
        end
      end
    end

    context 'when Service Desk related params are set' do
      let(:params) { { service_desk_enabled: true } }

      before do
        allow(Gitlab::IncomingEmail).to receive(:enabled?) { true }
        allow(Gitlab::IncomingEmail).to receive(:supports_wildcard?) { true }
        stub_licensed_features(service_desk: true)
      end

      it 'updates Service Desk attributes' do
        action
        project.reload

        expect(response).to have_gitlab_http_status(:found)
        expect(project.service_desk_enabled).to eq(true)
      end
    end

    context 'when error occurs' do
      before do
        expect(::Projects::UpdateService)
          .to receive_message_chain(:new, :execute)
          .and_return({ status: :error, message: 'Error' })
      end

      it_behaves_like 'action pushing protected branches data to gon'
    end

    context 'when merge_pipelines_enabled param is specified' do
      let(:params) { { merge_pipelines_enabled: true } }

      before do
        stub_licensed_features(merge_pipelines: true)
      end

      it 'updates the attribute' do
        action

        expect(project.reload.merge_pipelines_enabled).to be_truthy
      end

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(merge_pipelines: false)
        end

        it 'does not update the attribute' do
          action

          expect(project.reload.merge_pipelines_enabled).to be_falsy
        end
      end

      context 'when lisence is not sufficient' do
        before do
          stub_licensed_features(merge_pipelines: false)
        end

        it 'does not update the attribute' do
          action

          expect(project.reload.merge_pipelines_enabled).to be_falsy
        end
      end
    end

    context 'repository mirrors' do
      let(:params) do
        {
          mirror: true,
          mirror_trigger_builds: true,
          mirror_user_id: user.id,
          import_url: 'https://example.com'
        }
      end

      context 'when licensed' do
        before do
          stub_licensed_features(repository_mirrors: true)
        end

        it 'updates repository mirror attributes' do
          expect_any_instance_of(EE::ProjectImportState).to receive(:force_import_job!).once

          action
          project.reload

          expect(project.mirror).to eq(true)
          expect(project.mirror_trigger_builds).to eq(true)
          expect(project.mirror_user).to eq(user)
          expect(project.import_url).to eq('https://example.com')
        end
      end

      context 'when unlicensed' do
        before do
          stub_licensed_features(repository_mirrors: false)
        end

        it 'does not update repository mirror attributes' do
          params.each do |param, _value|
            expect do
              action
              project.reload
            end.not_to change(project, param)
          end
        end
      end
    end
  end

  describe '#download_export' do
    let(:request) { get :download_export, params: { namespace_id: project.namespace, id: project } }

    context 'when project export is enabled' do
      it 'logs the audit event' do
        expect { request }.to change { SecurityEvent.count }.by(1)
      end
    end

    context 'when project export is disabled' do
      before do
        stub_application_setting(project_export_enabled?: false)
      end

      it 'does not log an audit event' do
        expect { request }.not_to change { SecurityEvent.count }
      end
    end
  end

  context 'Archive & Unarchive actions' do
    let(:group) { create(:group) }
    let(:project) { create(:project, group: group) }
    let(:archived_project) { create(:project, :archived, group: group) }

    describe 'POST #archive' do
      let(:request) { post :archive, params: { namespace_id: project.namespace, id: project } }

      context 'for a user with the ability to archive a project' do
        before do
          group.add_owner(user)
        end

        it 'logs the audit event' do
          expect { request }.to change { SecurityEvent.count }.by(1)
          expect(SecurityEvent.last.details[:custom_message]).to eq('Project archived')
        end
      end

      context 'for a user that does not have the ability to archive a project' do
        before do
          project.add_maintainer(user)
        end

        it 'does not log the audit event' do
          expect { request }.not_to change { SecurityEvent.count }
        end
      end
    end

    describe 'POST #unarchive' do
      let(:request) { post :unarchive, params: { namespace_id: archived_project.namespace, id: archived_project } }

      context 'for a user with the ability to unarchive a project' do
        before do
          group.add_owner(user)
        end

        it 'logs the audit event' do
          expect { request }.to change { SecurityEvent.count }.by(1)
          expect(SecurityEvent.last.details[:custom_message]).to eq('Project unarchived')
        end
      end

      context 'for a user that does not have the ability to unarchive a project' do
        before do
          project.add_maintainer(user)
        end

        it 'does not log the audit event' do
          expect { request }.not_to change { SecurityEvent.count }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:owner) { create(:user) }
    let(:project) { create(:project, namespace: owner.namespace)}
    let(:action) { delete :destroy, params: { namespace_id: project.namespace, id: project } }

    before do
      controller.instance_variable_set(:@project, project)
      sign_in(owner)
    end

    context 'feature is available' do
      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: true)
      end

      it 'marks project for deletion' do
        action

        expect(project.reload.marked_for_deletion?).to be_truthy
        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(project_path(project))
      end

      context 'when error occurs' do
        let(:message) { 'Error' }

        before do
          expect(::Projects::MarkForDeletionService)
            .to receive_message_chain(:new, :execute)
            .and_return({ status: :error, message: message })
        end

        it_behaves_like 'action pushing protected branches data to gon'

        it 'does not mark project for deletion' do
          action

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:edit)
          expect(flash[:alert]).to include(message)
        end
      end

      context 'when instance setting is set to 0 days' do
        it 'deletes project right away' do
          allow(Gitlab::CurrentSettings).to receive(:deletion_adjourned_period).and_return(0)

          action

          expect(project.marked_for_deletion?).to be_falsey
          expect(response).to have_gitlab_http_status(:found)
          expect(response).to redirect_to(dashboard_projects_path)
        end
      end
    end

    context 'feature is not available' do
      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: false)
      end

      it 'deletes project right away' do
        action

        expect(project.marked_for_deletion?).to be_falsey
        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(dashboard_projects_path)
      end
    end
  end

  describe 'POST #restore' do
    let(:owner) { create(:user) }
    let(:project) { create(:project, namespace: owner.namespace)}
    let(:action) { post :restore, params: { namespace_id: project.namespace, project_id: project } }

    before do
      controller.instance_variable_set(:@project, project)
      sign_in(owner)
    end

    it 'restores project deletion' do
      action

      expect(project.reload.marked_for_deletion_at).to be_nil
      expect(project.reload.archived).to be_falsey
      expect(response).to have_gitlab_http_status(:found)
      expect(response).to redirect_to(edit_project_path(project))
    end

    context 'when error occurs' do
      let(:message) { 'Error' }

      before do
        expect(::Projects::RestoreService)
          .to receive_message_chain(:new, :execute)
          .and_return({ status: :error, message: message })
      end

      it_behaves_like 'action pushing protected branches data to gon'

      it 'does not restore project' do
        action

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to include(message)
      end
    end
  end
end
