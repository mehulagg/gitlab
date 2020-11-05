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
end
