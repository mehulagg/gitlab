# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectsController do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  describe "GET show" do
    let(:public_project) { create(:project, :public, :repository) }

    render_views

    subject { get :show, params: { namespace_id: public_project.namespace.path, id: public_project.path } }

    it 'shows the over size limit warning message if above_size_limit' do
      allow_next_instance_of(Gitlab::RepositorySizeChecker) do |checker|
        expect(checker).to receive(:above_size_limit?).and_return(true)
      end
      allow(controller).to receive(:current_user).and_return(user)

      subject

      expect(response.body).to match(/The size of this repository.+exceeds the limit/)
    end

    it 'does not show an over size warning if not above_size_limit' do
      subject

      expect(response.body).not_to match(/The size of this repository.+exceeds the limit/)
    end

    context 'namespace storage limit' do
      let(:namespace) { public_project.namespace }

      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      it_behaves_like 'namespace storage limit alert'
    end
  end

  describe 'GET edit' do
    it 'does not allow an auditor user to access the page' do
      sign_in(create(:user, :auditor))

      get :edit,
          params: {
            namespace_id: project.namespace.path,
            id: project.path
          }

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
      let(:project_template) { create(:project, :repository, :public, :metrics_dashboard_enabled, namespace: group) }
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
    it 'updates EE attributes' do
      params = {
        repository_size_limit: 1024
      }

      put :update,
          params: {
            namespace_id: project.namespace,
            id: project,
            project: params
          }
      project.reload

      expect(response).to have_gitlab_http_status(:found)
      params.except(:repository_size_limit).each do |param, value|
        expect(project.public_send(param)).to eq(value)
      end
      expect(project.repository_size_limit).to eq(params[:repository_size_limit].megabytes)
    end

    it 'updates Merge Request Approvers attributes' do
      params = {
        approvals_before_merge: 50,
        approver_group_ids: create(:group).id,
        approver_ids: create(:user).id,
        reset_approvals_on_push: false
      }

      put :update,
          params: {
            namespace_id: project.namespace,
            id: project,
            project: params
          }
      project.reload

      expect(response).to have_gitlab_http_status(:found)
      expect(project.approver_groups.pluck(:group_id)).to contain_exactly(params[:approver_group_ids])
      expect(project.approvers.pluck(:user_id)).to contain_exactly(params[:approver_ids])
    end

    it 'updates Issuable Default Templates attributes' do
      params = {
        issues_template: 'You got issues?',
        merge_requests_template: 'I got tissues'
      }

      put :update,
          params: {
            namespace_id: project.namespace,
            id: project,
            project: params
          }
      project.reload

      expect(response).to have_gitlab_http_status(:found)
      params.each do |param, value|
        expect(project.public_send(param)).to eq(value)
      end
    end

    context 'when merge_pipelines_enabled param is specified' do
      let(:params) { { merge_pipelines_enabled: true } }

      let(:request) do
        put :update, params: { namespace_id: project.namespace, id: project, project: params }
      end

      before do
        stub_licensed_features(merge_pipelines: true)
      end

      it 'updates the attribute' do
        request

        expect(project.reload.merge_pipelines_enabled).to be_truthy
      end

      context 'when feature flag is disabled' do
        before do
          stub_feature_flags(merge_pipelines: false)
        end

        it 'does not update the attribute' do
          request

          expect(project.reload.merge_pipelines_enabled).to be_falsy
        end
      end

      context 'when lisence is not sufficient' do
        before do
          stub_licensed_features(merge_pipelines: false)
        end

        it 'does not update the attribute' do
          request

          expect(project.reload.merge_pipelines_enabled).to be_falsy
        end
      end
    end

    context 'repository mirrors' do
      let(:params) do
        {
          mirror: true,
          mirror_trigger_builds: true,
          import_url: 'https://example.com'
        }
      end

      context 'when licensed' do
        before do
          stub_licensed_features(repository_mirrors: true)
        end

        it 'updates repository mirror attributes' do
          expect_any_instance_of(EE::ProjectImportState).to receive(:force_import_job!).once

          put :update,
            params: {
              namespace_id: project.namespace,
              id: project,
              project: params
            }
          project.reload

          expect(project.mirror).to eq(true)
          expect(project.mirror_trigger_builds).to eq(true)
          expect(project.mirror_user).to eq(user)
          expect(project.import_url).to eq('https://example.com')
        end

        it 'ignores mirror_user_id' do
          other_user = create(:user)

          put :update,
            params: {
              namespace_id: project.namespace,
              id: project,
              project: params.merge(mirror_user_id: other_user.id)
            }
          project.reload

          expect(project.mirror_user).to eq(user)
        end
      end

      context 'when unlicensed' do
        before do
          stub_licensed_features(repository_mirrors: false)
        end

        it 'does not update repository mirror attributes' do
          params.each do |param, _value|
            expect do
              put :update,
                params: {
                  namespace_id: project.namespace,
                  id: project,
                  project: params
                }
              project.reload
            end.not_to change(project, param)
          end
        end
      end
    end

    context 'merge request approvers settings' do
      shared_examples 'merge request approvers rules' do
        using RSpec::Parameterized::TableSyntax

        where(:license_value, :setting_value, :param_value, :final_value) do
          false | false | false | false
          false | true  | false | false
          false | false | true  | true
          false | true  | true  | true
          true  | false | false | false
          true  | true  | false | false
          true  | false | true  | true
          true  | true  | true  | true
        end

        with_them do
          before do
            stub_licensed_features(admin_merge_request_approvers_rules: license_value)
            stub_application_setting(app_setting => setting_value)
          end

          it 'updates project if needed' do
            put :update,
              params: {
                namespace_id: project.namespace,
                id: project,
                project: { setting => param_value }
              }

            project.reload

            expect(project[setting]).to eq(final_value)
          end
        end
      end

      describe ':disable_overriding_approvers_per_merge_request' do
        it_behaves_like 'merge request approvers rules' do
          let(:app_setting) { :disable_overriding_approvers_per_merge_request }
          let(:setting) { :disable_overriding_approvers_per_merge_request }
        end
      end

      describe ':merge_requests_author_approval' do
        it_behaves_like 'merge request approvers rules' do
          let(:app_setting) { :prevent_merge_requests_author_approval }
          let(:setting) { :merge_requests_author_approval }
        end
      end

      describe ':merge_requests_disable_committers_approval' do
        it_behaves_like 'merge request approvers rules' do
          let(:app_setting) { :prevent_merge_requests_committers_approval }
          let(:setting) { :merge_requests_disable_committers_approval }
        end
      end
    end

    context 'compliance framework settings' do
      let(:framework) { ComplianceManagement::Framework::DEFAULT_FRAMEWORKS.last }
      let(:params) { { compliance_framework_setting_attributes: { framework: framework.identifier } } }

      context 'when unlicensed' do
        before do
          stub_licensed_features(compliance_framework: false)
        end

        it 'ignores any compliance framework params' do
          put :update,
            params: {
                namespace_id: project.namespace,
                id: project,
                project: params
            }
          project.reload

          expect(project.compliance_framework_setting).to be_nil
        end
      end

      context 'when licensed' do
        before do
          stub_licensed_features(compliance_framework: true)
        end

        it 'sets the compliance framework' do
          put :update,
              params: {
                  namespace_id: project.namespace,
                  id: project,
                  project: params
              }
          project.reload

          expect(project.compliance_framework_setting.compliance_management_framework.name).to eq(framework.name)
        end
      end
    end
  end

  describe '#download_export' do
    let(:request) { get :download_export, params: { namespace_id: project.namespace, id: project } }

    context 'when project export is enabled' do
      it 'logs the audit event' do
        expect { request }.to change { AuditEvent.count }.by(1)
      end
    end

    context 'when project export is disabled' do
      before do
        stub_application_setting(project_export_enabled?: false)
      end

      it 'does not log an audit event' do
        expect { request }.not_to change { AuditEvent.count }
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
          expect { request }.to change { AuditEvent.count }.by(1)
          expect(AuditEvent.last.details[:custom_message]).to eq('Project archived')
        end
      end

      context 'for a user that does not have the ability to archive a project' do
        before do
          project.add_maintainer(user)
        end

        it 'does not log the audit event' do
          expect { request }.not_to change { AuditEvent.count }
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
          expect { request }.to change { AuditEvent.count }.by(1)
          expect(AuditEvent.last.details[:custom_message]).to eq('Project unarchived')
        end
      end

      context 'for a user that does not have the ability to unarchive a project' do
        before do
          project.add_maintainer(user)
        end

        it 'does not log the audit event' do
          expect { request }.not_to change { AuditEvent.count }
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:owner) { create(:user) }
    let(:group) { create(:group) }
    let(:project) { create(:project, group: group)}

    before do
      group.add_user(owner, Gitlab::Access::OWNER)
      controller.instance_variable_set(:@project, project)
      sign_in(owner)
    end

    shared_examples 'deletes project right away' do
      it do
        delete :destroy, params: { namespace_id: project.namespace, id: project }

        expect(project.marked_for_deletion?).to be_falsey
        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(dashboard_projects_path)
      end
    end

    shared_examples 'marks project for deletion' do
      it do
        delete :destroy, params: { namespace_id: project.namespace, id: project }

        expect(project.reload.marked_for_deletion?).to be_truthy
        expect(response).to have_gitlab_http_status(:found)
        expect(response).to redirect_to(project_path(project))
      end
    end

    context 'feature is available' do
      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: true)
      end

      context 'when feature is enabled for group' do
        before do
          allow(group).to receive(:delayed_project_removal?).and_return(true)
        end

        it_behaves_like 'marks project for deletion'

        it 'does not mark project for deletion because of error' do
          message = 'Error'

          expect(::Projects::MarkForDeletionService).to receive_message_chain(:new, :execute).and_return({ status: :error, message: message })

          delete :destroy, params: { namespace_id: project.namespace, id: project }

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:edit)
          expect(flash[:alert]).to include(message)
        end

        context 'when instance setting is set to 0 days' do
          it 'deletes project right away' do
            stub_application_setting(deletion_adjourned_period: 0)

            delete :destroy, params: { namespace_id: project.namespace, id: project }

            expect(project.marked_for_deletion?).to be_falsey
            expect(response).to have_gitlab_http_status(:found)
            expect(response).to redirect_to(dashboard_projects_path)
          end
        end
      end

      context 'when feature is disabled for group' do
        before do
          allow(group).to receive(:delayed_project_removal).and_return(false)
        end

        it_behaves_like 'deletes project right away'
      end

      context 'for projects in user namespace' do
        let(:project) { create(:project, namespace: owner.namespace)}

        it_behaves_like 'deletes project right away'
      end
    end

    context 'feature is not available' do
      before do
        stub_licensed_features(adjourned_deletion_for_projects_and_groups: false)
      end

      it_behaves_like 'deletes project right away'
    end
  end

  describe 'POST #restore' do
    let(:owner) { create(:user) }
    let(:project) { create(:project, namespace: owner.namespace)}

    before do
      controller.instance_variable_set(:@project, project)
      sign_in(owner)
    end

    it 'restores project deletion' do
      post :restore, params: { namespace_id: project.namespace, project_id: project }

      expect(project.reload.marked_for_deletion_at).to be_nil
      expect(project.reload.archived).to be_falsey
      expect(response).to have_gitlab_http_status(:found)
      expect(response).to redirect_to(edit_project_path(project))
    end

    it 'does not restore project because of error' do
      message = 'Error'
      expect(::Projects::RestoreService).to receive_message_chain(:new, :execute).and_return({ status: :error, message: message })

      post :restore, params: { namespace_id: project.namespace, project_id: project }

      expect(response).to have_gitlab_http_status(:ok)
      expect(response).to render_template(:edit)
      expect(flash[:alert]).to include(message)
    end
  end
end
