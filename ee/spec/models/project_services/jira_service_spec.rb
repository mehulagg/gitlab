# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraService do
  let(:jira_service) { build(:jira_service, **options) }

  let(:options) do
    {
      url: 'http://jira.example.com',
      username: 'gitlab_jira_username',
      password: 'gitlab_jira_password',
      project_key: 'GL'
    }
  end

  describe 'validations' do
    it 'validates presence of project_key if issues_enabled' do
      jira_service.project_key = ''
      jira_service.issues_enabled = true

      expect(jira_service).to be_invalid
    end
  end

  describe '#new_issue_url_with_predefined_fields' do
    before do
      allow(jira_service).to receive(:jira_project_id).and_return('11223')
      allow(jira_service).to receive(:vulnerabilities_issuetype).and_return('10001')
    end

    let(:expected_new_issue_url) { '/secure/CreateIssueDetails!init.jspa?pid=11223&issuetype=10001&summary=Special+Summary%21%3F&description=%2AID%2A%3A+2%0A_Issue_%3A+%21' }

    subject(:new_issue_url) { jira_service.new_issue_url_with_predefined_fields("Special Summary!?", "*ID*: 2\n_Issue_: !") }

    it { is_expected.to eq(expected_new_issue_url) }
  end

  describe '#jira_project_id' do
    let(:jira_service) { described_class.new(options) }
    let(:project_info_result) { { 'id' => '10000' } }

    subject(:jira_project_id) { jira_service.jira_project_id }

    before do
      WebMock.stub_request(:get, /api\/2\/project\/GL/).with(basic_auth: %w(gitlab_jira_username gitlab_jira_password)).to_return(body: project_info_result.to_json )
    end

    it { is_expected.to eq('10000') }
  end
end
