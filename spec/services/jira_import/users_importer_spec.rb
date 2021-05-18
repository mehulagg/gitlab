# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraImport::UsersImporter do
  include JiraServiceHelper

  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:project, reload: true) { create(:project, group: group) }
  let_it_be(:start_at) { 7 }

  let(:importer) { described_class.new(user, project, start_at) }

  subject { importer.execute }

  describe '#execute' do
    let(:mapped_users) do
      [
        {
          jira_account_id: 'acc1',
          jira_display_name: 'user-name1',
          jira_email: 'sample@jira.com',
          gitlab_id: project_member.id
        },
        {
          jira_account_id: 'acc2',
          jira_display_name: 'user-name2',
          jira_email: nil,
          gitlab_id: group_member.id
        }
      ]
    end

    before do
      stub_jira_service_test
      project.add_maintainer(user)
    end

    context 'when Jira import is not configured properly' do
      it 'returns an error' do
        expect(subject.errors).to eq(['Jira integration not configured.'])
      end
    end

    RSpec.shared_examples 'maps Jira users to GitLab users' do
      context 'when Jira import is configured correctly' do
        let_it_be(:jira_service) { create(:jira_service, project: project, active: true, url: "http://jira.example.net") }
        let(:client) { double }

        context 'when Jira client raises an error' do
          let(:error) { Timeout::Error.new }

          it 'returns an error response' do
            expect(client).to receive(:get).and_raise(error)
            expect(Gitlab::ErrorTracking).to receive(:log_exception).with(error, project_id: project.id)

            expect(subject.error?).to be_truthy
            expect(subject.message).to include('There was an error when communicating to Jira')
          end
        end

        context 'when Jira client returns result' do
          context 'when Jira client returns an empty array' do
            let(:jira_users) { [] }

            it 'returns nil payload' do
              expect(subject.success?).to be_truthy
              expect(subject.payload).to be_empty
            end
          end

          context 'when Jira client returns any users' do
            let_it_be(:project_member) { create(:user, email: 'sample@jira.com') }
            let_it_be(:group_member) { create(:user, name: 'user-name2') }
            let_it_be(:other_user) { create(:user) }

            before do
              project.add_developer(project_member)
              group.add_developer(group_member)
            end

            it 'returns the mapped users' do
              expect(subject.success?).to be_truthy
              expect(subject.payload).to eq(mapped_users)
            end
          end
        end
      end
    end

    context 'when Jira instance is of Server deployment type' do
      let(:server_info_attrs) do
        {
          "baseUrl" => "http://jira.reali.sh:8080",
          "version" => "8.16.1",
          "versionNumbers" => [8, 16, 1],
          "deploymentType" => "Server",
          "buildNumber" => 816001,
          "buildDate" => "2021-04-19T00:00:00.000+0000",
          "databaseBuildNumber" => 816001,
          "serverTime" => "2021-05-18T19:18:11.236+0000",
          "scmInfo" => "b8b28db1b682e9a8568ad9c3cfad139bae9ed93f",
          "serverTitle" => "JIRA"
        }
      end

      let(:deployment_type) { 'server' }
      let(:url) { "/rest/api/2/user/search?username=''&maxResults=50&startAt=#{start_at}" }

      let(:jira_users) do
        [
          { 'key' => 'acc1', 'name' => 'user-name1', 'emailAddress' => 'sample@jira.com' },
          { 'key' => 'acc2', 'name' => 'user-name2' }
        ]
      end

      before do
        allow(importer).to receive(:deployment_type).and_return(deployment_type)
        allow(project).to receive(:jira_service).and_return(jira_service)
        allow(jira_service).to receive(:client).and_return(client)
        allow(client).to receive_message_chain(:ServerInfo, :all, :attrs).and_return(server_info_attrs)
        allow(client).to receive(:get).with(url).and_return(jira_users)
      end

      it_behaves_like 'maps Jira users to GitLab users'
    end

    context 'when Jira instance is of Cloud deployment type' do
      let(:server_info_attrs) do
        {
          "baseUrl" => "https://gitlab-stage-protect.atlassian.net",
          "version" => "1001.0.0-SNAPSHOT",
          "versionNumbers" => [1001, 0, 0],
          "deploymentType" => "Cloud",
          "buildNumber" => 100161,
          "buildDate" => "2021-05-17T04:58:39.000-1000",
          "serverTime" => "2021-05-18T08:59:51.341-1000",
          "scmInfo" => "68a3d2e8029d1c8b542176202f79ee1f9c2df6f9",
          "serverTitle" => "Jira",
          "defaultLocale" => {
            "locale" => "en_US"
          }
        }
      end

      let(:deployment_type) { 'cloud' }
      let(:url) { "/rest/api/2/users?maxResults=50&startAt=#{start_at}" }

      let(:jira_users) do
        [
          { 'accountId' => 'acc1', 'displayName' => 'user-name1', 'emailAddress' => 'sample@jira.com' },
          { 'accountId' => 'acc2', 'displayName' => 'user-name2' }
        ]
      end

      before do
        allow(importer).to receive(:deployment_type).and_return(deployment_type)
        allow(project).to receive(:jira_service).and_return(jira_service)
        allow(jira_service).to receive(:client).and_return(client)
        allow(client).to receive_message_chain(:ServerInfo, :all, :attrs).and_return(server_info_attrs)
        allow(client).to receive(:get).with(url).and_return(jira_users)
      end

      it_behaves_like 'maps Jira users to GitLab users'
    end
  end
end
