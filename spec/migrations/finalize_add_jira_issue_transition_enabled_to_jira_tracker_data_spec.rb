# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe FinalizeAddJiraIssueTransitionEnabledToJiraTrackerData do
  let(:services) { table(:services) }
  let(:jira_tracker_data) { table(:jira_tracker_data) }

  let!(:jira_service1) { services.create!(id: 1, type: 'JiraService') }
  let!(:jira_service2) { services.create!(id: 2, type: 'JiraService') }
  let!(:jira_service3) { services.create!(id: 3, type: 'JiraService') }
  let!(:jira_service4) { services.create!(id: 4, type: 'JiraService') }
  let!(:jira_service5) { services.create!(id: 5, type: 'JiraService') }

  let!(:jira_tracker_data1) { jira_tracker_data.create!(id: 1, service_id: 1, jira_issue_transition_enabled: true, jira_issue_transition_id: '123') }
  let!(:jira_tracker_data2) { jira_tracker_data.create!(id: 2, service_id: 2, jira_issue_transition_enabled: false, jira_issue_transition_id: '123') }
  let!(:jira_tracker_data3) { jira_tracker_data.create!(id: 3, service_id: 3, jira_issue_transition_enabled: nil, jira_issue_transition_id: nil) }
  let!(:jira_tracker_data4) { jira_tracker_data.create!(id: 4, service_id: 4, jira_issue_transition_enabled: nil, jira_issue_transition_id: '') }
  let!(:jira_tracker_data5) { jira_tracker_data.create!(id: 5, service_id: 5, jira_issue_transition_enabled: nil, jira_issue_transition_id: '123') }

  it 'correctly updates all jira_tracker_data records' do
    migrate!

    expect(jira_tracker_data1.reload.jira_issue_transition_enabled).to be(true)
    expect(jira_tracker_data2.reload.jira_issue_transition_enabled).to be(false)
    expect(jira_tracker_data3.reload.jira_issue_transition_enabled).to be(false)
    expect(jira_tracker_data4.reload.jira_issue_transition_enabled).to be(false)
    expect(jira_tracker_data5.reload.jira_issue_transition_enabled).to be(true)
  end
end
