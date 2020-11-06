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
end
