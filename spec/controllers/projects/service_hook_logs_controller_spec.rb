# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::ServiceHookLogsController do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user) }
  let(:integration) { create(:drone_ci_integration, project: project) }
  let(:log) { create(:web_hook_log, web_hook: integration.service_hook) }
  let(:log_params) do
    {
      namespace_id: project.namespace,
      project_id: project,
      service_id: integration.to_param,
      id: log.id
    }
  end

  before do
    sign_in(user)
    project.add_maintainer(user)
  end

  describe 'GET #show' do
    subject { get :show, params: log_params }

    specify do
      expect(response).to be_successful
    end
  end

  describe 'POST #retry' do
    subject { post :retry, params: log_params }

    it 'executes the hook and redirects to the service form' do
      expect_any_instance_of(ServiceHook).to receive(:execute)
      expect_any_instance_of(described_class).to receive(:set_hook_execution_notice)
      expect(subject).to redirect_to(edit_project_service_path(project, integration))
    end
  end
end
