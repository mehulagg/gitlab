# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::ServicesHelper do
  let(:controller_class) do
    Class.new(ActionController::Base) do
      include EE::ServicesHelper

      def slack_auth_project_settings_slack_url(project)
        "http://some-path/project/1"
      end
    end
  end

  let_it_be_with_refind(:project) { create(:project) }

  subject { controller_class.new }

  describe '#integration_form_data' do
    subject { helper.integration_form_data(integration) }

    before do
      assign(:project, project)
    end

    context 'Slack service' do
      let(:integration) { build(:slack_service) }

      it 'does not include Jira specific fields' do
        is_expected.not_to include(:show_jira_issues_integration, :show_jira_vulnerabilities_integration, :enable_jira_issues, :project_key, :gitlab_issues_enabled, :edit_project_path)
      end
    end

    context 'Jira service' do
      let_it_be_with_refind(:integration) { create(:jira_service, project: project, issues_enabled: true, project_key: 'FE', vulnerabilities_enabled: true, vulnerabilities_issuetype: '10001') }

      context 'when there is no license for jira_vulnerabilities_integration' do
        before do
          stub_feature_flags(jira_for_vulnerabilities: true)
        end

        it 'includes Jira specific fields' do
          is_expected.to include(show_jira_vulnerabilities_integration: 'false')
        end
      end

      context 'when flag is disabled for jira_for_vulnerabilities' do
        before do
          stub_licensed_features(jira_issues_integration: true, jira_vulnerabilities_integration: true)
          stub_feature_flags(jira_for_vulnerabilities: false)
        end

        it 'includes Jira specific fields' do
          is_expected.to include(show_jira_vulnerabilities_integration: 'false')
        end
      end

      context 'when all flags are enabled' do
        before do
          stub_licensed_features(jira_issues_integration: true, jira_vulnerabilities_integration: true)
          stub_feature_flags(jira_for_vulnerabilities: true)
        end

        it 'includes Jira specific fields' do
          is_expected.to include(
            show_jira_issues_integration: 'true',
            show_jira_vulnerabilities_integration: 'true',
            enable_jira_issues: 'true',
            enable_jira_vulnerabilities: 'true',
            project_key: 'FE',
            vulnerabilities_issuetype: '10001',
            gitlab_issues_enabled: 'true',
            edit_project_path: edit_project_path(project, anchor: 'js-shared-permissions')
          )
        end
      end
    end
  end

  describe '#add_to_slack_link' do
    it 'encodes a masked CSRF token' do
      expect(subject).to receive(:form_authenticity_token).and_return('a token')
      slack_link = subject.add_to_slack_link(project, '123456')

      expect(slack_link).to start_with('https://slack.com/oauth/authorize')
      expect(slack_link).to include('redirect_uri=http://some-path/project/1&state=a+token')
    end
  end
end
