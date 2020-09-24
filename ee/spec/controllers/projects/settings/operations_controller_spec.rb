# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Settings::OperationsController do
  let_it_be(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'GET show' do
    shared_examples 'user without read access' do |project_visibility, project_role|
      let(:project) { create(:project, project_visibility) }

      before do
        project.add_role(user, project_role)
      end

      it 'returns 404' do
        get :show, params: project_params(project)

        expect(response).to have_gitlab_http_status(:not_found)
      end
    end

    shared_examples 'user with read access' do |project_visibility|
      let(:project) { create(:project, project_visibility) }

      before do
        project.add_maintainer(user)
      end

      it 'renders ok' do
        get :show, params: project_params(project)

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:show)
      end
    end

    shared_examples 'user needs to login' do |project_visibility|
      it 'redirects for private project' do
        project = create(:project, project_visibility)

        get :show, params: project_params(project)

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a license' do
      before do
        stub_licensed_features(tracing: true, incident_management: true)
      end

      context 'with maintainer role' do
        it_behaves_like 'user with read access', :public
        it_behaves_like 'user with read access', :private
        it_behaves_like 'user with read access', :internal
      end

      context 'without maintainer role' do
        %w[guest reporter developer].each do |role|
          it_behaves_like 'user without read access', :public, role
          it_behaves_like 'user without read access', :private, role
          it_behaves_like 'user without read access', :internal, role
        end
      end

      context 'when user not logged in' do
        before do
          sign_out(user)
        end

        it_behaves_like 'user without read access', :public, :maintainer

        it_behaves_like 'user needs to login', :private
        it_behaves_like 'user needs to login', :internal
      end
    end

    context 'without license' do
      before do
        stub_licensed_features(tracing: false, incident_management: false)
      end

      it_behaves_like 'user with read access', :public
      it_behaves_like 'user with read access', :private
      it_behaves_like 'user with read access', :internal
    end
  end

  describe 'PATCH update' do
    let(:public_project) { create(:project, :public) }
    let(:private_project) { create(:project, :private) }
    let(:internal_project) { create(:project, :internal) }

    before do
      public_project.add_maintainer(user)
      private_project.add_maintainer(user)
      internal_project.add_maintainer(user)
    end

    shared_examples 'user without write access' do |project_visibility, project_role|
      let(:project) { create(:project, project_visibility) }

      before do
        project.add_role(user, project_role)
      end

      it 'does not create tracing_setting' do
        update_project(
          project,
          tracing_params: { external_url: 'https://gitlab.com' }
        )

        expect(project.tracing_setting).to be_nil
      end

      it 'does not create status_page_setting' do
        update_project(
          project,
          status_page_params: attributes_for(:status_page_setting)
        )

        expect(project.status_page_setting).to be_nil
      end
    end

    context 'format html' do
      let(:project) { create(:project) }
      let(:operations_update_service) { spy(:operations_update_service) }

      before do
        stub_licensed_features(tracing: true)

        project.add_maintainer(user)
      end

      context 'when update succeeds' do
        before do
          stub_operations_update_service_returning(status: :success)
        end

        it 'shows a notice' do
          update_project(project, tracing_params: { external_url: 'http://gitlab.com' })

          expect(response).to redirect_to(project_settings_operations_url(project))
          expect(flash[:notice]).to eq _('Your changes have been saved')
        end
      end

      context 'when update fails' do
        before do
          stub_operations_update_service_returning(status: :error)
        end

        it 'renders show page' do
          update_project(project, tracing_params: { external_url: 'http://gitlab.com' })

          expect(response).to have_gitlab_http_status(:ok)
          expect(response).to render_template(:show)
        end
      end
    end

    context 'with a license' do
      before do
        stub_licensed_features(tracing: true, incident_management: true, status_page: true)
      end

      shared_examples 'user with write access' do |project_visibility|
        let(:project) { create(:project, project_visibility) }
        let(:tracing_url) { 'https://gitlab.com' }

        before do
          project.add_maintainer(user)
        end

        it 'creates tracing setting' do
          update_project(
            project,
            tracing_params: { external_url: tracing_url }
          )

          expect(project.tracing_setting.external_url).to eq(tracing_url)
        end
      end

      context 'with maintainer role' do
        it_behaves_like 'user with write access', :public
        it_behaves_like 'user with write access', :private
        it_behaves_like 'user with write access', :internal
      end

      context 'with non maintainer roles' do
        %w[guest reporter developer].each do |role|
          context "with #{role} role" do
            it_behaves_like 'user without write access', :public, role
            it_behaves_like 'user without write access', :private, role
            it_behaves_like 'user without write access', :internal, role
          end
        end
      end

      context 'with anonymous user' do
        before do
          sign_out(user)
        end

        it_behaves_like 'user without write access', :public, :maintainer
        it_behaves_like 'user without write access', :private, :maintainer
        it_behaves_like 'user without write access', :internal, :maintainer
      end

      context 'with existing tracing_setting' do
        let(:project) { create(:project) }

        before do
          project.create_tracing_setting!(external_url: 'https://gitlab.com')
          project.add_maintainer(user)
        end

        it 'unsets external_url with nil' do
          update_project(project, tracing_params: { external_url: nil })

          expect(project.tracing_setting).to be_nil
        end

        it 'unsets external_url with empty string' do
          update_project(project, tracing_params: { external_url: '' })

          expect(project.tracing_setting).to be_nil
        end

        it 'fails validation with invalid url' do
          expect do
            update_project(project, tracing_params: { external_url: "invalid" })
          end.not_to change(project.tracing_setting, :external_url)
        end

        it 'does not set external_url if not present in params' do
          expect do
            update_project(project, tracing_params: { some_param: 'some_value' })
          end.not_to change(project.tracing_setting, :external_url)
        end
      end

      context 'without existing tracing_setting' do
        let(:project) { create(:project) }

        before do
          project.add_maintainer(user)
        end

        it 'fails validation with invalid url' do
          update_project(project, tracing_params: { external_url: "invalid" })

          expect(project.tracing_setting).to be_nil
        end

        it 'does not set external_url if not present in params' do
          update_project(project, tracing_params: { some_param: 'some_value' })

          expect(project.tracing_setting).to be_nil
        end
      end

      context 'updating tracing settings' do
        let(:project) { create(:project) }
        let(:new_tracing_settings) { {} }

        before do
          project.add_maintainer(user)
        end

        it 'creates a gitlab tracking event' do
          expect(Gitlab::Tracking).to receive(:event).with('project:operations:tracing', 'external_url_populated')
          update_project(project, tracing_params: { external_url: "http://example.com" } )
        end
      end

      context 'without existing status page setting' do
        let(:project) { create(:project) }

        before do
          project.add_maintainer(user)
        end

        subject(:status_page_setting) do
          valid_attributes = attributes_for(:status_page_setting).except(:enabled)
          update_project(project, status_page_params: valid_attributes )

          project.status_page_setting
        end

        it { is_expected.to be_a(StatusPage::ProjectSetting) }
      end

      context 'with existing status page setting' do
        let(:project) { create(:project) }
        let(:status_page_attributes) { attributes_for(:status_page_setting) }

        before do
          project.add_maintainer(user)
          project.create_status_page_setting!(status_page_attributes)
        end

        it 'updates the fields' do
          update_project(project, status_page_params: status_page_attributes.merge(aws_s3_bucket_name: 'test'))

          expect(project.status_page_setting.aws_s3_bucket_name).to eq('test')
        end

        it 'respects the model validations' do
          old_name = project.status_page_setting.aws_s3_bucket_name

          update_project(project, status_page_params: status_page_attributes.merge(aws_s3_bucket_name: ''))
          expect(project.status_page_setting.aws_s3_bucket_name).to eq(old_name)
        end

        it 'deletes the setting if keys removed' do
          update_project(
            project,
            status_page_params: status_page_attributes.merge(aws_access_key: '',
                                                              aws_secret_key: '',
                                                              aws_s3_bucket_name: '',
                                                              aws_region: '',
                                                              status_page_url: '')
          )
          expect(project.status_page_setting).to be_nil
        end
      end
    end

    context 'without a license' do
      before do
        stub_licensed_features(tracing: false, incident_management: false, status_page: false)
      end

      it_behaves_like 'user without write access', :public, :maintainer
      it_behaves_like 'user without write access', :private, :maintainer
      it_behaves_like 'user without write access', :internal, :maintainer
    end

    private

    def update_project(project, tracing_params: nil, incident_management_params: nil, status_page_params: nil)
      patch :update, params: project_params(
        project,
        tracing_params: tracing_params,
        incident_management_params: incident_management_params,
        status_page_params: status_page_params
      )

      project.reload
    end
  end

  private

  def project_params(project, tracing_params: nil, incident_management_params: nil, status_page_params: nil)
    {
      namespace_id: project.namespace,
      project_id: project,
      project: {
        tracing_setting_attributes: tracing_params,
        incident_management_setting_attributes: incident_management_params,
        status_page_setting_attributes: status_page_params
      }
    }
  end

  def stub_operations_update_service_returning(return_value = {})
    expect(::Projects::Operations::UpdateService)
      .to receive(:new).with(project, user, anything)
      .and_return(operations_update_service)
    expect(operations_update_service).to receive(:execute)
      .and_return(return_value)
  end
end
