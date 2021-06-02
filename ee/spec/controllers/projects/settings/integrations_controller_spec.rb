# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Settings::IntegrationsController do
  let_it_be(:project) { create(:project, :public) }
  let_it_be(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  shared_examples 'endpoint with some disabled services' do
    it 'has some disabled services' do
      get :show, params: { namespace_id: project.namespace, project_id: project }

      expect(active_services).not_to include(*disabled_services)
    end
  end

  shared_examples 'endpoint without disabled services' do
    it 'does not have disabled services' do
      get :show, params: { namespace_id: project.namespace, project_id: project }

      expect(active_services).to include(*disabled_services)
    end
  end

  context 'sets correct services list' do
    let(:active_services) { assigns(:integrations).map(&:type) }
    let(:disabled_services) { %w[GithubService] }

    it 'enables SlackSlashCommandsService and disables GitlabSlackApplication' do
      get :show, params: { namespace_id: project.namespace, project_id: project }

      expect(active_services).to include('SlackSlashCommandsService')
      expect(active_services).not_to include('GitlabSlackApplicationService')
    end

    it 'enables GitlabSlackApplication and disables SlackSlashCommandsService' do
      stub_application_setting(slack_app_enabled: true)
      allow(::Gitlab).to receive(:com?).and_return(true)

      get :show, params: { namespace_id: project.namespace, project_id: project }

      expect(active_services).to include('GitlabSlackApplicationService')
      expect(active_services).not_to include('SlackSlashCommandsService')
    end

    context 'without a license key' do
      it_behaves_like 'endpoint with some disabled services'
    end

    context 'with a license key' do
      let_it_be(:namespace) { create(:group, :private) }
      let_it_be(:project) { create(:project, :private, namespace: namespace) }

      before do
        create(:license, plan: ::License::PREMIUM_PLAN)
      end

      context 'when checking if namespace plan is enabled' do
        before do
          stub_application_setting(check_namespace_plan: true)
        end

        it_behaves_like 'endpoint with some disabled services'
      end

      context 'when checking if namespace plan is not enabled' do
        before do
          stub_application_setting(check_namespace_plan: false)
        end

        it_behaves_like 'endpoint without disabled services'
      end
    end
  end
end
