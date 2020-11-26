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

    it 'validates presence of project_key if vulnerabilities_enabled' do
      jira_service.project_key = ''
      jira_service.vulnerabilities_enabled = true

      expect(jira_service).to be_invalid
    end

    it 'validates presence of vulnerabilities_issuetype if vulnerabilities_enabled' do
      jira_service.vulnerabilities_issuetype = ''
      jira_service.vulnerabilities_enabled = true

      expect(jira_service).to be_invalid
    end
  end

  describe 'jira_vulnerabilities_integration_enabled?' do
    subject(:jira_vulnerabilities_integration_enabled) { jira_service.jira_vulnerabilities_integration_enabled? }

    context 'when integration is not configured for the project' do
      let(:options) { { project: nil } }

      it { is_expected.to be_falsey }
    end

    context 'when jira integration is not available for the project' do
      before do
        allow(jira_service.project).to receive(:jira_vulnerabilities_integration_available?).and_return(false)
      end

      context 'when vulnerabilities_enabled is set to false' do
        before do
          allow(jira_service).to receive(:vulnerabilities_enabled).and_return(false)
        end

        it { is_expected.to eq(false) }
      end

      context 'when vulnerabilities_enabled is set to true' do
        before do
          allow(jira_service).to receive(:vulnerabilities_enabled).and_return(true)
        end

        it { is_expected.to eq(false) }
      end
    end

    context 'when jira integration is available for the project' do
      before do
        allow(jira_service.project).to receive(:jira_vulnerabilities_integration_available?).and_return(true)
      end

      context 'when vulnerabilities_enabled is set to false' do
        before do
          allow(jira_service).to receive(:vulnerabilities_enabled).and_return(false)
        end

        it { is_expected.to eq(false) }
      end

      context 'when vulnerabilities_enabled is set to true' do
        before do
          allow(jira_service).to receive(:vulnerabilities_enabled).and_return(true)
        end

        it { is_expected.to eq(true) }
      end
    end
  end

  describe '#issue_types' do
    subject(:issue_types) { jira_service.issue_types }

    let(:client) { double(Issuetype: issue_type_jira_resource) }
    let(:issue_type_jira_resource) { double(all: jira_issue_types) }
    let(:jira_issue_types) { [double(subtask: true), double(subtask: false, id: '10001', name: 'Bug', description: 'Jira Bug')] }

    before do
      allow(jira_service.project).to receive(:jira_vulnerabilities_integration_enabled?).and_return(true)
      allow(jira_service).to receive(:client).and_return(client)
    end

    it 'loads all issue types without subtask issue types' do
      expect(issue_types).to eq([{ id: '10001', name: 'Bug', description: 'Jira Bug' }])
    end
  end

  describe '#test' do
    subject(:jira_test) { jira_service.test(nil) }

    context 'when server is not responding' do
      before do
        allow(jira_service).to receive(:server_info).and_return(nil)
      end

      it { is_expected.to eq(success: false, result: nil) }
    end

    context 'when server is responding' do
      before do
        allow(jira_service).to receive(:server_info).and_return({ jira: true })
      end

      context 'when vulnerabilities integration is not enabled' do
        before do
          allow(jira_service.project).to receive(:jira_vulnerabilities_integration_enabled?).and_return(false)
        end

        it { is_expected.to eq(success: true, result: { jira: true }) }
      end

      context 'when vulnerabilities integration is enabled' do
        before do
          allow(jira_service.project).to receive(:jira_vulnerabilities_integration_enabled?).and_return(true)
          allow(jira_service).to receive(:issue_types).and_return([{ id: '10001', name: 'Bug', description: 'Jira Bug' }])
        end

        it { is_expected.to eq(success: true, result: { jira: true }, data: { issuetypes: [{ id: '10001', name: 'Bug', description: 'Jira Bug' }] }) }
      end
    end
  end

  describe '#create_issue' do
    let(:jira_service) { described_class.new(options) }
    let(:issue_info) { { 'id': '10000' } }

    before do
      allow(jira_service).to receive(:jira_project_id).and_return('11223')
      allow(jira_service).to receive(:vulnerabilities_issuetype).and_return('10001')
    end

    context 'when there is no issues in Jira API' do
      before do
        WebMock.stub_request(:post, 'http://jira.example.com/rest/api/2/issue').with(basic_auth: %w(gitlab_jira_username gitlab_jira_password)).to_return(body: issue_info.to_json)
      end

      it 'creates issue in Jira API' do
        issue = jira_service.create_issue("Special Summary!?", "*ID*: 2\n_Issue_: !")

        expect(WebMock).to have_requested(:post, 'http://jira.example.com/rest/api/2/issue').with(
          body: { fields: { project: { id: '11223' }, issuetype: { id: '10001' }, summary: 'Special Summary!?', description: "*ID*: 2\n_Issue_: !" } }.to_json
        ).once
        expect(issue.id).to eq('10000')
      end
    end

    context 'when there is an error in Jira' do
      let(:errors) { { 'errorMessages' => [], 'errors' => { 'summary' => 'You must specify a summary of the issue.' } } }

      before do
        WebMock.stub_request(:post, 'http://jira.example.com/rest/api/2/issue').with(basic_auth: %w(gitlab_jira_username gitlab_jira_password)).to_return(status: [400, 'Bad Request'], body: errors.to_json)
      end

      it 'returns issue with errors' do
        issue = jira_service.create_issue('', "*ID*: 2\n_Issue_: !")

        expect(WebMock).to have_requested(:post, 'http://jira.example.com/rest/api/2/issue').with(
          body: { fields: { project: { id: '11223' }, issuetype: { id: '10001' }, summary: '', description: "*ID*: 2\n_Issue_: !" } }.to_json
        ).once
        expect(issue.attrs[:errors]).to eq(errors)
      end
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
