# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraService do
  let(:jira_service) { build(:jira_service) }

  describe 'validations' do
    it 'validates presence of project_key if issues_enabled' do
      jira_service.project_key = ''
      jira_service.issues_enabled = true

      expect(jira_service).to be_invalid
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
end
