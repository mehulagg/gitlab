# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe CleanupJiraTrackerDataDeploymentType, :migration do
  let(:integrations_table) { table(:integrations) }
  let(:jira_tracker_data) { Gitlab::BackgroundMigration::UpdateJiraTrackerDataDeploymentTypeBasedOnUrl::JiraTrackerData }
  let(:jira_integration) { integrations_table.create!(id: 1, type: 'Jira') }

  let!(:tracker_data_cloud) { jira_tracker_data.create!(id: 1, service_id: jira_integration.id, url: "https://test-domain.atlassian.net", deployment_type: 0) }
  let!(:tracker_data_server) { jira_tracker_data.create!(id: 2, service_id: jira_integration.id, url: "http://totally-not-jira-server.company.org", deployment_type: 0) }

  it 'migrates the remaining records' do
    expect { migrate! }.to change { tracker_data_cloud.reload.deployment_type }.from('unknown').to('cloud')
                       .and change { tracker_data_server.reload.deployment_type }.from('unknown').to('server')
  end
end
