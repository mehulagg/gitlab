# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::RemoveDuplicateServices, :migration, schema: 20201207165956 do
  let_it_be(:users) { table(:users) }
  let_it_be(:namespaces) { table(:namespaces) }
  let_it_be(:projects) { table(:projects) }
  let_it_be(:services) { table(:services) }

  let_it_be(:alerts_service_data) { table(:alerts_service_data) }
  let_it_be(:chat_names) { table(:chat_names) }
  let_it_be(:issue_tracker_data) { table(:issue_tracker_data) }
  let_it_be(:jira_tracker_data) { table(:jira_tracker_data) }
  let_it_be(:open_project_tracker_data) { table(:open_project_tracker_data) }
  let_it_be(:slack_integrations) { table(:slack_integrations) }
  let_it_be(:web_hooks) { table(:web_hooks) }

  let_it_be(:data_tables) do
    [alerts_service_data, chat_names, issue_tracker_data, jira_tracker_data, open_project_tracker_data, slack_integrations, web_hooks]
  end

  before do
    users.create(id: 1, projects_limit: 100)
    namespaces.create(id: 1, name: 'group', path: 'group')

    projects.create(id: 1, namespace_id: 1) # normal services
    projects.create(id: 2, namespace_id: 1) # duplicate services
    projects.create(id: 3, namespace_id: 1) # dependant records
    projects.create(id: 4, namespace_id: 1) # no services

    # normal services
    services.create(id: 1, project_id: 1, type: 'AsanaService')
    services.create(id: 2, project_id: 1, type: 'JiraService')
    services.create(id: 3, project_id: 1, type: 'SlackService')

    # duplicate services
    services.create(id: 4, project_id: 2, type: 'AsanaService')
    services.create(id: 5, project_id: 2, type: 'JiraService')
    services.create(id: 6, project_id: 2, type: 'JiraService')
    services.create(id: 7, project_id: 2, type: 'SlackService')
    services.create(id: 8, project_id: 2, type: 'SlackService')
    services.create(id: 9, project_id: 2, type: 'SlackService')

    # dependant records
    services.create(id: 10, project_id: 3, type: 'AlertsService')
    services.create(id: 11, project_id: 3, type: 'AlertsService')
    services.create(id: 12, project_id: 3, type: 'SlashCommandsService')
    services.create(id: 13, project_id: 3, type: 'SlashCommandsService')
    services.create(id: 14, project_id: 3, type: 'IssueTrackerService')
    services.create(id: 15, project_id: 3, type: 'IssueTrackerService')
    services.create(id: 16, project_id: 3, type: 'JiraService')
    services.create(id: 17, project_id: 3, type: 'JiraService')
    services.create(id: 18, project_id: 3, type: 'OpenProjectService')
    services.create(id: 19, project_id: 3, type: 'OpenProjectService')
    services.create(id: 20, project_id: 3, type: 'SlackService')
    services.create(id: 21, project_id: 3, type: 'SlackService')

    alerts_service_data.create(id: 1, service_id: 10)
    alerts_service_data.create(id: 2, service_id: 11)
    chat_names.create(id: 1, service_id: 12, user_id: 1, team_id: 'team1', chat_id: 'chat1')
    chat_names.create(id: 2, service_id: 13, user_id: 1, team_id: 'team2', chat_id: 'chat2')
    issue_tracker_data.create(id: 1, service_id: 14)
    issue_tracker_data.create(id: 2, service_id: 15)
    jira_tracker_data.create(id: 1, service_id: 16)
    jira_tracker_data.create(id: 2, service_id: 17)
    open_project_tracker_data.create(id: 1, service_id: 18)
    open_project_tracker_data.create(id: 2, service_id: 19)
    slack_integrations.create(id: 1, service_id: 20, user_id: 1, team_id: 'team1', team_name: 'team1', alias: 'alias1')
    slack_integrations.create(id: 2, service_id: 21, user_id: 1, team_id: 'team2', team_name: 'team2', alias: 'alias2')
    web_hooks.create(id: 1, service_id: 20)
    web_hooks.create(id: 2, service_id: 21)
  end

  it 'removes duplicate services and dependant records' do
    # Determine which services we expect to keep
    expected_services = described_class::Project.all.each_with_object({}) do |project, map|
      types = project.services.map(&:type).uniq
      map[project.id] = types.map { |type| project.find_service(type).id }
    end

    expect do
      subject.perform(1, 3)
    end.to change { services.count }.from(21).to(12)

    services1 = services.where(project_id: 1)
    expect(services1.count).to be(3)
    expect(services1.pluck(:type)).to contain_exactly('AsanaService', 'JiraService', 'SlackService')
    expect(services1.pluck(:id)).to contain_exactly(*expected_services[1])

    services2 = services.where(project_id: 2)
    expect(services2.count).to be(3)
    expect(services2.pluck(:type)).to contain_exactly('AsanaService', 'JiraService', 'SlackService')
    expect(services2.pluck(:id)).to contain_exactly(*expected_services[2])

    services3 = services.where(project_id: 3)
    expect(services3.count).to be(6)
    expect(services3.pluck(:type)).to contain_exactly('AlertsService', 'SlashCommandsService', 'IssueTrackerService', 'JiraService', 'OpenProjectService', 'SlackService')
    expect(services3.pluck(:id)).to contain_exactly(*expected_services[3])

    kept_services = expected_services.values.flatten
    data_tables.each do |table|
      expect(table.count).to be(1)
      expect(kept_services).to include(table.pluck(:service_id).first)
    end
  end

  it 'skips projects outside of the range' do
    expect do
      subject.perform(5, 6)
    end.not_to change { services.count }

    expect do
      subject.perform(3, 4)
    end.to change { services.count }.by(-6)
  end
end
